"""一次性：创建 healthchecks 超级用户 admin / hc123456"""
import os
import sys

sys.path.insert(0, r"D:/code/workbuddy/workbuddy-project/python/web-api/healthchecks")
sys.path.insert(0, r"D:/code/workbuddy/workbuddy-project/python/web-api/_stub")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "hc.settings")
os.environ.setdefault("SECRET_KEY", "hc-demo-2026")
os.environ.setdefault("PYTHONPATH", r"D:/code/workbuddy/workbuddy-project/python/web-api/_stub")

import django  # noqa: E402

django.setup()

from django.contrib.auth import get_user_model  # noqa: E402

U = get_user_model()
if not U.objects.filter(username="admin").exists():
    U.objects.create_superuser("admin", "admin@example.org", "hc123456")
    print("OK 已创建超级用户 admin / hc123456")
else:
    print("OK 超级用户已存在")
print("用户总数:", U.objects.count())
