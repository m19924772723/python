"""FastAPI 精选项目演示应用 —— TODO 待办 API。

特性演示：
- 类型驱动：Pydantic 模型即文档、即校验（标题长度/优先级枚举）
- REST 完整 CRUD（内存存储，重启即清空）
- 自动生成 Swagger 交互文档 /docs 与 ReDoc /redoc
"""
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field

app = FastAPI(
    title="FastAPI Demo · TODO API",
    description="精选项目 fastapi/fastapi 的演示服务：类型驱动 + 自动文档",
    version="1.0.0",
)


class TodoIn(BaseModel):
    title: str = Field(..., min_length=1, max_length=50, examples=["学 FastAPI"])
    priority: int = Field(1, ge=1, le=5, description="优先级 1~5，5 最高")
    done: bool = False


class Todo(TodoIn):
    id: int


DB: dict[int, Todo] = {}
NEXT_ID = 1


@app.get("/", tags=["meta"])
def root():
    return {
        "name": "FastAPI Demo",
        "framework": f"fastapi (源码安装于 ../fastapi)",
        "docs": "/docs  Swagger 交互文档",
        "redoc": "/redoc  ReDoc 文档",
        "endpoints": ["/todos", "/todos/{id}"],
    }


@app.get("/todos", response_model=list[Todo], tags=["todo"])
def list_todos(
    done: bool | None = Query(None, description="按完成状态过滤"),
    q: str | None = Query(None, min_length=1, max_length=20, description="标题关键词"),
):
    items = list(DB.values())
    if done is not None:
        items = [t for t in items if t.done == done]
    if q:
        items = [t for t in items if q in t.title]
    return items


@app.post("/todos", response_model=Todo, status_code=201, tags=["todo"])
def create_todo(data: TodoIn):
    global NEXT_ID
    todo = Todo(id=NEXT_ID, **data.model_dump())
    DB[NEXT_ID] = todo
    NEXT_ID += 1
    return todo


@app.get("/todos/{todo_id}", response_model=Todo, tags=["todo"])
def get_todo(todo_id: int):
    if todo_id not in DB:
        raise HTTPException(404, f"todo {todo_id} 不存在")
    return DB[todo_id]


@app.put("/todos/{todo_id}", response_model=Todo, tags=["todo"])
def update_todo(todo_id: int, data: TodoIn):
    if todo_id not in DB:
        raise HTTPException(404, f"todo {todo_id} 不存在")
    DB[todo_id] = Todo(id=todo_id, **data.model_dump())
    return DB[todo_id]


@app.delete("/todos/{todo_id}", tags=["todo"])
def delete_todo(todo_id: int):
    if todo_id not in DB:
        raise HTTPException(404, f"todo {todo_id} 不存在")
    return {"deleted": DB.pop(todo_id).title}


@app.get("/health", tags=["meta"])
def health():
    return {"status": "ok", "todos": len(DB)}
