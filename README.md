# mccPi
Raspberry Pi Mobile Command Center

## Golden-path deploy (required)

All testing and validation starts from the same deploy path used by users.

From a Windows PowerShell prompt:

1. `ssh radio@mccpi.local`
2. `sudo su`
3. Run the deploy script via curl:

	`curl -fsSL https://raw.githubusercontent.com/huntd69/mccPi/main/deploy.sh | bash`
