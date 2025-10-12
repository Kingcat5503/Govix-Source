build-iso.sh

This script wraps mkarchiso to build an ISO from the `releng` directory.

Usage

  ./build-iso.sh [options]

Options:
  -r, --releng DIR       Path to releng directory (default: ./releng)
  -o, --output DIR       Output directory for generated ISO (default: ./builds)
  -w, --workdir DIR      Work directory for mkarchiso (default: ~/.cache/archiso-workdir)
      --keep-workdir     Don't remove workdir after build
  -h, --help             Show help

Examples

  # Build using defaults (releng in repository, output to ./builds)
  ./build-iso.sh

  # Specify custom releng and keep the workdir for inspection
  ./build-iso.sh -r /path/to/releng -o /tmp/isos --keep-workdir

Notes

- The script requires `mkarchiso` (from the `archiso` package) to be installed and will fail if missing.
- The script runs `mkarchiso` under sudo because mkarchiso typically needs root privileges to create loopback mounts and write to the workdir.
- Adjust paths as needed for your environment.
