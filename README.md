# PostgreSQL

Asynchronous client in pure Swift with [cooperative multitasking](https://github.com/swiftstack/fiber). **No callbacks.**

```swift
.package(url: "https://github.com/swiftstack/postgresql.git", .branch("fiber"))
```

## Usage

```swift
import Async
import PostgreSQL

async {
    let client = PostgreSQL.Client(host: "127.0.0.1", port: 5432)
    try client.connect(user: "postgres")
    let result = try client.query("select * from rows;")
    print(result)
}

loop.run()
```

```bash
$ swift run
```
