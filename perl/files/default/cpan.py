#!/bin/env python

"""Expect script for CPAN.

Takes a list of commandline arguments, which are passed in sequence to cpan.
"""

import sys, os, re

# must be installed
import pexpect

CONF = r'Are you ready for manual configuration\?'
PROMPT = r'cpan> '
DEFAULT = r'\[.+\]\s*$'
MAKE_ERROR = r'\nmake: \*\*\* \[.+\] Error \d+'
CONFLICT_ERROR = r'kill (\d+)\.'
UNCLEAN_ERROR = r'Other job not responding\.'

def cpan():
    # need a longer timeout for cpan than 30s
    return pexpect.spawn('cpan', timeout=120, logfile=sys.stdout)

def main(argv):
    child = cpan()
    try:
        while True:
            i = child.expect([CONFLICT_ERROR, UNCLEAN_ERROR, CONF, PROMPT])
            if i == 0:
                os.system('kill %s' % child.match.group(1))
                child.close()
                child = cpan()
            elif i == 1:
                child.sendline('Y')
            elif i == 2:
                child.sendline('no')
            else:
                break
        for cmd in argv[1:]:
            child.sendline(cmd)
            while True:
                i = child.expect([DEFAULT, PROMPT])
                m = re.search(MAKE_ERROR, child.before)
                if m:
                    raise RuntimeError(m.group(0))
                if i == 0:
                    child.sendline('')
                else:
                    break
    finally:
        child.sendline('quit')
        child.expect(pexpect.EOF)
        child.close()

if __name__ == '__main__':
    main(sys.argv)
