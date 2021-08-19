# PostgreSQL

Asynchronous client in pure Swift

```swift
.package(url: "https://github.com/swiftstack/postgresql.git", .branch("dev"))
```

## Usage

```swift
import PostgreSQL

let client = PostgreSQL.Client(host: "127.0.0.1", port: 5432)
try await client.connect(user: "postgres")
let result = try await client.query("select * from rows;")
print(result)
```

```bash
$ swift run
```
