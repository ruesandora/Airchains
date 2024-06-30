# AirchainsMonitor

AirchainsMonitor is a Bash script designed to monitor and maintain the Airchains network node. It provides automatic error detection, RPC endpoint replacement and system maintenance for Airchains validators.

## Features

- Automatic monitoring of the Airchains network
- Identifying and addressing common errors
- Dynamic switching between multiple RPC endpoints
- Automatic rollback and restart of `stationd` service
- Colorful and informative console printout

## Auto Installation

1. Type the following command and it will run directly.
   ```
   curl -sL1https://raw.githubusercontent.com/Dwtexe/Airchains-MonitorAddon/main/AirchainsMonitor.sh | bash
   ```

## Manual Installation

1. Find the file `AirchainsMonitor.sh` in the repo and open it.
2. Type `cd tracks/` and enter the directory.
3. Create a file by typing `nano AirchainsMonitor.sh`.
4. Copy and paste `AirchainsMonitor.sh` from the repo.
5. Press `CTRL + X` and save it by pressing `Y`.
6. Make the file available by typing `chmod +x AirchainsMonitor.sh`.
7. You can run the last code with `./AirchainsMonitor.sh`.

```
./AirchainsMonitor.sh
```

The script will do the following:
1. stop the `stationd` service
2. Perform a rollback operation
3. Restart the `stationd` service
4. Clear system logs
5. Start monitoring the Airchains network

## Monitoring Process

The script continuously monitors the Airchains network for various issues, including
- Failed transactions
- VRF verification errors
- Client connection errors
- RPC errors
- Inadequate fee errors

When an error is detected, the script will do the following:
1. Display an error message
2. Switch to a different RPC endpoint
3. Perform a rollback operation
4. Restart the `stationd` service

## Privatization

You can customize the script by changing the following:

- RPC endpoints: Update the `RPC_ENDPOINTS` array with your preferred endpoints.
- Error detection: Modify the `process_log_line` function to add or remove error patterns.

## Support

If you find this script useful, you might consider supporting the developer:

- Created by: @dwtexe
- Donation address: air1dksx7yskxthlycnhvkvxs8c452f9eus5cxh6t5

## Disclaimer

This script is provided as is, without any warranty of any kind. Use at your own risk and always make sure to take proper backups of your node data.

## License

This project is open source and available under the [MIT License](https://opensource.org/licenses/MIT).

Translated with www.DeepL.com/Translator (free version)
