#!/usr/bin/env python3

import re
import sys

LINE_SPLIT_PATTERN = re.compile('(?<!:):(?!:)')

def parse_game_line(line):
    game = {}
    for field in re.split(LINE_SPLIT_PATTERN, line.strip()):
        if not field.strip():
            continue
        k, v = field.split('=', 1)
        k = k.strip()
        v = v.strip().replace("::", ":")
        game[k] = v
    return game

def print_result_line(medal, game):
    datestamp = str(int(game['end'][:8]) + 100) # Month is 0-indexed
    timestamp = game['end'][8:14]
    url = '/morgue/{name}/morgue-{name}-{date}-{time}.txt'.format(name=game['name'], date=datestamp, time=timestamp)
    link = '<a href="{url}">{name}</a>'.format(url=url, name=game['name'])
    if game.get('ktyp') == 'winning':
        explanation = game['vmsg']
    else:
        explanation = "dead on {loc} ({vmsg})".format(loc=game['place'], vmsg=game.get('vmsg', game.get('tmsg', '???')))
    print("{medal} {link} with {score:,} points, {explanation}<br>".format(link=link, score=int(game['sc']), explanation=explanation, medal=medal))

def next_valid_game(score_lines, existing_winners):
    '''Find the next game which isn't by an existing winner, or None if there isn't.'''
    while True:
        if not score_lines:
            return None
        game = parse_game_line(score_lines.pop(0))
        if game['name'] in existing_winners:
            continue
        return game

score_lines = []
with open('/var/dcss/gamedata/dcss-experimental-weekly-challenge/save/scores') as f:
    for line in f:
        score_lines.append(line.strip())

if not score_lines:
    print("Nobody has finished a game yet!")

medals = ["🥇", "🥈", "🥉"]
winners = set()
for medal in medals:
    game = next_valid_game(score_lines, winners)
    if not game:
        break
    winners.add(game['name'])
    print_result_line(medal, game)
