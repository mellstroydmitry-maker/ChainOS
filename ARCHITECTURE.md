# ChainOS Architecture

ChainOS is designed as a foundation for experimental and custom
mobile operating systems.

The project is intentionally modular.

## Design goals

- minimal base system
- modular components
- reproducible builds
- hardware independence where possible
- understandable source tree
- developer-friendly tooling
- no unnecessary proprietary dependencies

## Layers

### 1. Boot

Responsible for bringing the device from firmware to the
ChainOS kernel.

### 2. Kernel

Provides:

- process management
- memory management
- scheduling
- networking
- filesystem support
- hardware interfaces

### 3. Hardware abstraction

Provides a stable interface between hardware drivers and
higher-level ChainOS services.

### 4. System services

Core services include:

- init/service management
- networking
- power management
- audio
- graphics
- input
- storage
- device management

### 5. Chain API

The Chain API is the primary interface exposed to applications.

Applications should not need direct access to hardware.

### 6. UI

The graphical environment is intentionally separated from
the core system.

Different interfaces can be implemented without changing
the underlying system.

### 7. Applications

Applications use the Chain API rather than depending directly
on internal implementation details.
