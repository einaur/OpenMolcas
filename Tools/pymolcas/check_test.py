# -*- coding: utf-8 -*-

#***********************************************************************
# This file is part of OpenMolcas.                                     *
#                                                                      *
# OpenMolcas is free software; you can redistribute it and/or modify   *
# it under the terms of the GNU Lesser General Public License, v. 2.1. *
# OpenMolcas is distributed in the hope that it will be useful, but it *
# is provided "as is" and without any express or implied warranties.   *
# For more details see the full text of the license in the file        *
# LICENSE or in <http://www.gnu.org/licenses/>.                        *
#                                                                      *
# Copyright (C) 2017-2019, Ignacio Fdez. Galván                        *
#***********************************************************************

from __future__ import (unicode_literals, division, absolute_import, print_function)

from os.path import basename
from re import compile as re_compile
from molcas_aux import *

def check_test(infofile, checkfile, count):
  block = re_compile(r'#>>\s*(\d+)')
  reference = re_compile(r'#>\s*(.*)="(.*)"\/(.*)')
  rc = '_RC_ALL_IS_WELL_'
  last = True

  # Read actual values from the calculation
  vals = []
  try:
    with utf8_open(infofile) as i_file:
      for line in i_file:
        if (line.lstrip()[0] == '*'):
          continue
        match = reference.match(line)
        if match:
          try:
            vals.append({'lab': match.group(1),
                         'val': float(match.group(2)),
                         'tol': int(match.group(3)),
                         'raw': line.strip()})
          except:
            print('*** Error in {0}: {1}'.format(basename(infofile), line.rstrip()))
            return '_RC_CHECK_ERROR_'
  except:
    pass

  # If generating check file, write the values
  if (get_utf8('MOLCAS_TEST', default='').upper().startswith('GENE')):
    try:
      maxcount = int(get_utf8('MOLCAS_MAX_CHECKS', default=''))
    except:
      maxcount = 500
    if (count > maxcount):
      print('*** Too many program calls in test file')
      return '_RC_CHECK_ERROR_'
    print('\nGenerating check file')
    if (count == 1):
      with utf8_open(checkfile, 'w') as c_file:
        c_file.write('* This file is autogenerated:\n')
        for line in get_utf8('MOLCAS_INFO', default='').split('!'):
          prefix = '*'
          if (len(line) > 0):
            prefix += ' '
          c_file.write('{0}{1}\n'.format(prefix, line))
    with utf8_open(checkfile, 'a') as c_file:
      c_file.write('#>> {0:3}\n'.format(count))
      for item in vals:
        c_file.write('{0}\n'.format(item['raw']))

  # If checking, read the reference values
  elif (get_utf8('MOLCAS_TEST', default='').upper().startswith('CHECK')):
    start = False
    refs = []
    try:
      with utf8_open(checkfile) as c_file:
        for line in c_file:
          if (line.lstrip()[0] == '*'):
            continue
          match = block.match(line)
          if (match):
            if (start):
              last = False
              break
            if (int(match.group(1)) == count):
              start = True
            continue
          if (start):
            try:
              match = reference.match(line)
              refs.append({'lab': match.group(1),
                           'val': float(match.group(2)),
                           'tol': int(match.group(3))})
            except:
              print('*** Error in {0}: {1}'.format(basename(checkfile), line.rstrip()))
              return '_RC_CHECK_ERROR_'
    except:
      pass

    # Compare actual and reference values, and print summary
    start = False
    print('\nChecking results:')
    factor = int(get_utf8('MOLCAS_THR', default='0'))
    passcheck = int(get_utf8('MOLCAS_PASSCHECK', default='0'))
    failrc = '_RC_ALL_IS_WELL_' if (passcheck) else '_RC_CHECK_ERROR_'
    fuzzy = get_utf8('MOLCAS_CHECK_FUZZY', default='').upper()
    fuzzy = ((fuzzy == 'YES') or (fuzzy == 'ON'))
    if (factor > 0):
      print('\n*** Tolerance increased by a factor of {0}'.format(10**factor))
    else:
      factor = 0
    if (passcheck):
      print('\n*** This check is informative only, nothing fails')
    fmt_head = '\n{0:^30} {1:^20} {2:^20} {3:^9} {4:^9}'.format('Label','Value','Reference','Error','Tolerance')
    fmt_num = '{0:<30} {1:20.16g} {2:20.16g} {3:9.3e} {4:9.3e} {5}'
    fmt_rule = '-'*92
    j = -1
    failtol = False
    for i in range(len(refs)):
      # Find the corresponding item in the actual values
      j += 1
      extra = []
      while ((j < len(vals)) and (refs[i]['lab'] != vals[j]['lab'])):
        extra.append(vals[j]['lab'])
        j += 1
        if (not fuzzy):
          rc = failrc
      if (j >= len(vals)):
        print('*** Label not found: {0}'.format(refs[i]['lab']))
        rc = failrc
        break
      else:
        for item in extra:
          print('*** Extra label: {0}'.format(item))
      # Check the difference against the tolerance (with some dirty tricks)
      if (vals[j]['tol'] != refs[i]['tol']):
        failtol = True
      dif = abs(vals[j]['val'] - refs[i]['val'])
      tol = -refs[i]['tol']
      if (tol < 0):
        tol = 10**(tol+factor)
      else:
        tol = tol*10**(factor)
      if (dif > 0.0):
        if (not start):
          print(fmt_head)
          print(fmt_rule)
          start = True
        if (dif > tol):
          if ((refs[i]['lab'] == 'POTNUC') and (dif < tol*10)):
            tag = 'Skipped'
          elif (refs[i]['lab'].endswith('ITER') and (dif < tol+5)):
            tag = 'Skipped'
          else:
            tag = 'Failed'
            rc = failrc
        else:
          tag = ''
        print(fmt_num.format(refs[i]['lab'], vals[j]['val'], refs[i]['val'], dif, tol, tag))
    # Additional values at the end
    j += 1
    while (j < len(vals)):
      print('*** Extra label: {0}'.format(vals[j]['lab']))
      j += 1
      if (not fuzzy):
        rc = failrc
    if (failtol):
      print('*** Tolerances do not match')
      rc = failrc
    if (start):
      print(fmt_rule)
    elif (rc == '_RC_ALL_IS_WELL_'):
      print('All values match the reference')

  return rc, last
