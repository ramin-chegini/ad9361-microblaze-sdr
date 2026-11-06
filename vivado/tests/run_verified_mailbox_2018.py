"""Ramin: test the original project's modified mailbox using native Vivado 2018.3."""
from pathlib import Path
import argparse
import os
import subprocess

PROJECT = Path(__file__).resolve().parents[1]
ROOT = PROJECT.parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=ROOT/'.validation/ad9361_2018_mailbox')
    args = parser.parse_args()
    out = args.output.resolve(); out.mkdir(parents=True,exist_ok=True)
    vivado = Path(os.environ.get('VIVADO_2018',r'C:\Xilinx\Vivado\2018.3'))
    sources = PROJECT/'rtl'
    calls = [('xvlog',[sources/'axi_lite_drv.v',sources/'adaloop_top.v'],'compile_verilog',None),
             ('xvlog',['--sv',PROJECT/'tests/tb_verified_mailbox.sv'],'compile_test',None),
             ('xelab',['work.tb_verified_mailbox','-s','verified_mailbox'],'elaborate',None),
             ('xsim',['verified_mailbox','-runall','-onerror','quit','-onfinish','quit'],
              'simulate','AD9361_2018_MAILBOX_TESTS_PASSED')]
    for tool,arguments,label,marker in calls:
        result = subprocess.run(['cmd.exe','/c',str(vivado/'bin'/(tool+'.bat')),*map(str,arguments)],
                                cwd=out,capture_output=True,text=True,errors='replace')
        text = result.stdout+result.stderr
        (out/(label+'.log')).write_text(text,encoding='utf-8')
        if result.returncode or (marker and marker not in text):
            raise RuntimeError(label+'\n'+text[-4500:])
        print(label+' PASS',flush=True)
    print('AD9361_2018_MAILBOX_TESTS_PASSED',flush=True)


if __name__=='__main__':
    main()
