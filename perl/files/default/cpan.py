#!/bin/env python

import sys

# must be installed
import pexpect

CONF = 'Are you ready for manual configuration? [yes]'
PROMPT = 'cpan> '

def main(argv):
    child = pexpect.spawn('cpan')
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
    child.expect(PROMPT)
    child.sendline('quit')
    child.expect(pexpect.EOF)
    child.close()

if __name__ == '__main__':
    main(sys.argv)
