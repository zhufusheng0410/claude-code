# -*- coding: utf-8 -*-
"""DolphinScheduler 依赖图辅助。"""


def find_all_cycles(adj, maxlen=10):
    """枚举全部简单环（限制长度，避免组合爆炸）。"""
    cycles, seen = [], set()

    def dfs(path, inpath):
        for nxt in sorted(adj.get(path[-1], ())):
            if nxt == path[0]:
                key = tuple(sorted(path))
                if key not in seen:
                    seen.add(key)
                    cycles.append(list(path))
            elif nxt not in inpath and len(path) < maxlen:
                inpath.add(nxt)
                path.append(nxt)
                dfs(path, inpath)
                path.pop()
                inpath.discard(nxt)

    for start in sorted(adj):
        dfs([start], {start})
    return cycles
