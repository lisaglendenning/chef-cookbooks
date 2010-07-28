#!/bin/env python

import sys

# must be installed
import pexpect

CONF = 'Are you ready for manual configuration? [yes]'
PROMPT = 'cpan> '

def main(argv):
    # need a longer timeout for cpan
    child = pexpect.spawn('cpan', timeout=300, logfile=sys.stdout)
    try:
        i = child.expect_exact([CONF, PROMPT])
        if i == 0:
            child.sendline('no')
            child.expect(PROMPT)
        for cmd in argv[1:]:
            child.sendline(cmd)
            while True:
                i = child.expect_exact(['[yes]', PROMPT])
                if i == 0:
                    child.sendline('')
                else:
                    break
        child.sendline('quit')
        child.expect(pexpect.EOF)
    finally:
        child.close()

if __name__ == '__main__':
    main(sys.argv)
