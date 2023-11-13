# optimus-uniswap-x

Uniswap X substreams that converts the calldata of DutchActionOrders to DatabaseChanges.

## Running

### Prerequisites

- Docker and Docker compose
- Streaming fast API key. You can get one [here](https://app.streamingfast.io/)
- jq (for getting the token)

### Commands

Export your streaming fast API key: 

```bash
export STREAMINGFAST_KEY=server_123123 # Use your own API key
export SUBSTREAMS_API_TOKEN=$(curl https://auth.streamingfast.io/v1/auth/issue -s --data-binary '{"api_key":"'$STREAMINGFAST_KEY'"}' | jq -r .token)
```

Run your `docker-compose.yml`, it will build the Docker image, create a clickhouse instance for you:

```bash
docker compose up
```

Access your data using DBeaver connection via their Clickhouse driver:
- `host`: localhost:8123
- `user`: default
- `password`: default
- `database`: default


## Contributing

### Pre requisites

- [Rust v1.69+](https://rustup.rs/)
- [substreams](https://github.com/streamingfast/substreams/releases)
- [substreams-postgres-sql](https://github.com/streamingfast/substreams-sink-sql/releases)


### Install the toolchain

For building substreams, you have to use the WASM toolchain. Install it with:
```bash
rustup target add wasm32-unknown-unknown
```

After that, you can use the commands from `Makefile`:
|Command|Description|
|----------|---------|
|`make setup`|Setup the postgres database running the `schema.sql` script|
|`make build`|Build the substream module using the wasm toolchain|
|`make sink`|Run the `substreams-postgres-sql` process with your module|
