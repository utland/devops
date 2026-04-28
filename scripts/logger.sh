#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { 
    echo -e "${BLUE}[INFO]${NC} $1" 
}

log_success() { 
    echo -e "${GREEN}[OK]${NC} $1" 
}

log_warn() { 
    echo -e "${YELLOW}[WARN]${NC} $1" 
}

log_error() { 
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1 
}
