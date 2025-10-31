# Docker Network Watchdog

A simple bash script that monitors Docker networks and alerts you when networks are created outside your configured subnet range.

## Problem

Docker's `default-address-pools` configuration in `/etc/docker/daemon.json` only applies to networks created **without** explicit subnet definitions. When docker-compose files or `docker network create` commands specify custom subnets using `ipam:` configurations, they override the default pools.

This can lead to unexpected network ranges being used, potentially causing conflicts with your protected IP ranges.

## Solution

This watchdog script scans all Docker networks on every shell startup and alerts you immediately if any network exists outside your allowed range.

## Features

- **Automatic monitoring** on every shell startup
- **Color-coded alerts** for easy visibility
- **Zero dependencies** (uses only docker CLI)
- **Fast execution** (typically <100ms)
- **Non-intrusive** (only displays warnings when issues found)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/oriolrius/docker-network-watchdog.git ~/docker-network-watchdog
   ```

2. Make the script executable:
   ```bash
   chmod +x ~/docker-network-watchdog/check-docker-networks.sh
   ```

3. Add to your `.bashrc` or `.bash_profile`:
   ```bash
   # Check Docker networks for subnet conflicts on every shell
   if command -v docker &> /dev/null; then
       ~/docker-network-watchdog/check-docker-networks.sh
   fi
   ```

4. Customize the allowed range (optional):
   Edit `check-docker-networks.sh` and modify the `ALLOWED_RANGE` variable:
   ```bash
   ALLOWED_RANGE="10.222"  # Change to your subnet prefix
   ```

## Usage

The script runs automatically when you open a new shell. You can also run it manually:

```bash
~/docker-network-watchdog/check-docker-networks.sh
```

### Example Output

**When conflicts are found:**
```
=== Docker Network Check ===
⚠️  WARNING: Networks found outside 10.222.0.0/16 range!
  ✗ nifi_gitea-network: 172.21.0.0/16
  ✗ nifi_nifi-network: 172.20.0.0/16
```

**When all networks are compliant:**
```
=== Docker Network Check ===
✓ All networks in allowed range (10.222.0.0/16)
```

## Configuration

The script checks for networks outside the range defined by `ALLOWED_RANGE` variable:

```bash
ALLOWED_RANGE="10.222"  # Monitors for 10.222.0.0/16
```

To monitor a different range, simply change this value. For example:
- `ALLOWED_RANGE="172.20"` → monitors 172.20.0.0/16
- `ALLOWED_RANGE="192.168"` → monitors 192.168.0.0/16

## How It Works

1. Inspects all Docker networks using `docker network inspect`
2. Extracts subnet information from IPAM configuration
3. Compares each subnet against the allowed range
4. Displays color-coded warnings for any non-compliant networks

## Requirements

- Docker installed and accessible
- Bash shell
- Standard Unix utilities (awk, grep)

## Use Cases

- **Network segmentation enforcement** - Ensure all containers use designated IP ranges
- **Conflict prevention** - Avoid overlapping with VPN or corporate network ranges
- **Security compliance** - Monitor for unauthorized network configurations
- **Multi-environment management** - Detect when dev/staging networks leak into production ranges

## Troubleshooting

**Script doesn't run on shell startup:**
- Verify the script is executable: `ls -l ~/docker-network-watchdog/check-docker-networks.sh`
- Check your `.bashrc` includes the execution block
- Test manually: `~/docker-network-watchdog/check-docker-networks.sh`

**False positives:**
- Adjust `ALLOWED_RANGE` to match your actual subnet prefix
- Verify your `/etc/docker/daemon.json` has correct `default-address-pools`

**Docker permission errors:**
- Ensure your user is in the `docker` group: `sudo usermod -aG docker $USER`
- Logout and login again for group changes to take effect

## Related Configuration

Example `/etc/docker/daemon.json` configuration:

```json
{
  "experimental": true,
  "default-address-pools": [
    {
      "base": "10.222.0.0/16",
      "size": 24
    }
  ]
}
```

Remember: This configuration only affects networks created **without** explicit subnet definitions. This watchdog helps you catch when explicit subnets bypass these defaults.

## License

MIT License - Feel free to use and modify as needed.

## Contributing

Issues and pull requests welcome! Please feel free to improve the script or documentation.

## Author

Oriol Rius - [GitHub](https://github.com/oriolrius)
