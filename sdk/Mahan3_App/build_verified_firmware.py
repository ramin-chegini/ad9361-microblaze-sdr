"""Ramin: build the final AD9361 firmware against a generated MicroBlaze BSP."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess

PROJECT = Path(__file__).resolve().parent
SDK = PROJECT.parent
ROOT = SDK.parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--publish', action='store_true',
                        help='Copy the built ELF into the ignored Release directory.')
    parser.add_argument('--compiler', help='Path to mb-gcc; defaults to SDK 2018.3.')
    args = parser.parse_args()
    requested = args.compiler or os.environ.get('MB_GCC')
    candidates = ([requested] if requested else [
        r'C:\Xilinx\SDK\2018.3\gnu\microblaze\nt\bin\mb-gcc.exe',
        shutil.which('mb-gcc'),
    ])
    compiler = next((Path(x).resolve() for x in candidates if x and Path(x).is_file()), None)
    if compiler is None:
        raise SystemExit('Install SDK 2018.3, set MB_GCC, or pass --compiler to mb-gcc.')
    src = PROJECT/'src'
    bsp = SDK/'Mahan3_App_bsp/microblaze_0'
    if not (bsp/'include/xparameters.h').is_file() or not (bsp/'lib/libxil.a').is_file():
        raise SystemExit('Regenerate and build the microblaze_0 BSP in SDK first; see sdk/README.md.')
    out = ROOT/'.validation/firmware_build'
    out.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ)
    env['PATH'] = str(compiler.parent)+os.pathsep+env.get('PATH', '')
    # Ramin: retain the final application's legacy header globals with -fcommon.
    flags = ['-Wall', '-O1', '-fcommon', '-ffunction-sections', '-fdata-sections',
             '-mlittle-endian', '-mxl-barrel-shift', '-mxl-pattern-compare',
             '-mno-xl-soft-div', '-mcpu=v11.0', '-mno-xl-soft-mul',
             '-mxl-multiply-high', '-I'+str(bsp/'include')]
    sources = sorted(src.glob('*.c'))
    objects = []
    version = subprocess.check_output([str(compiler), '--version'], env=env, text=True)
    elf = out/'Mahan3_App.elf'
    with (out/'build.log').open('w', encoding='utf-8') as log:
        log.write(version)
        log.flush()
        for source in sources:
            target = out/(source.stem+'.o')
            objects.append(str(target))
            subprocess.run([str(compiler), *flags, '-c', str(source), '-o', str(target)],
                           env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
        subprocess.run([str(compiler), *flags, '-Wl,-T,'+str(src/'lscript.ld'),
                        '-L'+str(bsp/'lib'), '-Wl,--no-relax', '-Wl,--gc-sections',
                        '-o', str(elf), *objects, '-Wl,--start-group', '-lxil',
                        '-lgcc', '-lc', '-Wl,--end-group'],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    files = sources+sorted(src.glob('*.h'))+[src/'lscript.ld', bsp/'lib/libxil.a']
    manifest = {'compiler': str(compiler), 'compiler_version': version.strip(),
                'elf_sha256': digest(elf),
                'source_sha256': {x.relative_to(ROOT).as_posix(): digest(x) for x in files}}
    (out/'build_manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    if args.publish:
        target = PROJECT/'Release/Mahan3_App.elf'
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            shutil.copy2(target, out/'previous_Mahan3_App.elf')
        shutil.copy2(elf, target)
    print('AD9361_FIRMWARE_BUILD_PASSED '+digest(elf))
    print('ELF: '+str(target if args.publish else elf))


if __name__ == '__main__':
    main()
