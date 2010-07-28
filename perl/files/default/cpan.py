#!/bin/env python

import sys

# must be installed
import pexpect

CONF = r'Are you ready for manual configuration? \[yes\]'
PROMPT = r'cpan> '
MAKE_ERROR = r'\nmake: \*\*\* \[.+\] Error \d+'
UNCLEAN_ERROR = r'Other job not responding. Shall I overwrite the lockfile? \(Y/N\) \[y\]'

def main(argv):
    # need a longer timeout for cpan
    child = pexpect.spawn('cpan', timeout=300, logfile=sys.stdout)
    try:
        while True:
            i = child.expect([UNCLEAN_ERROR, CONF, PROMPT])
            if i == 0:
                child.sendline('')
            elif i == 1:
                child.sendline('no')
            else:
                break
        for cmd in argv[1:]:
            child.sendline(cmd)
            while True:
                i = child.expect([MAKE_ERROR, r'\[yes\]', PROMPT])
                if i == 0:
                    raise RuntimeError()
                elif i == 1:
                    child.sendline('')
                else:
                    break
    finally:
        child.sendline('quit')
        child.expect(pexpect.EOF)
        child.close()

if __name__ == '__main__':
    main(sys.argv)
