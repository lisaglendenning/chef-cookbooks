#!/bin/env python

import sys

# must be installed
import pexpect

PROMPT = 'cpan> '

def main(argv):
    child = pexpect.spawn('cpan')
    i = child.expect(['Are you ready for manual configuration? [yes] ', PROMPT])
    if i == 0:
        child.sendline('no')
        child.expect(PROMPT)
    else:
        for cmd in argv[1:]:
            child.sendline(cmd)
            child.expect(PROMPT)
        child.sendline('quit')

if __name__ == '__main__':
    main(sys.argv)
