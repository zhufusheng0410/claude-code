"""DolphinScheduler 部署文件中的命名依赖。"""
PLAN_SCHEMA = "dw-ds-deploy/v1"
SNAPSHOT_SCHEMA = "dw-ds-deploy/v2"


def dependency_groups(task):
    if "dependence" in task:
        return task["dependence"]["dependTaskList"]
    return [{"relation": "AND", "dependItemList": task.get("dependItems", [])}]


def dependency_items(task):
    for group in dependency_groups(task):
        yield from group["dependItemList"]
