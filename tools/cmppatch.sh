#!/bin/bash -e

REV1=
REV2=
RELPATH=

NEED_CHECKOUT=true

REVISIONS=(
    "a0ebea480bb3" # (tag: v5.15.24) Linux 5.15.24
    "177aa35b21c3" # pa-i2c-intel-ismt
    "5243c654ae60" # vfio_acs_quirks
    "c43c361ed0fd" # vfio_no_unsafe_reset
    "11aff1c65855" # vfio_memory_enable
    "79be5f91721d" # vfio_disable_D3
    "7b42eb0f82f6" # IR-2066: Enable GPIO for Broadwell
    "58b19846863a" # add MSR registers to show_regs
    "63243787374c" # fastrak-sd-error-loglevel
    "f004e992814b" # Linux kernel patch to change the eem packet driver to a multipacket handler
    "c5b3bedc2e3c" # Allow programming of additional MAC addresses for VF devices
    "90c9da8105fd" # printk: Print cpu number along with time
    "aeb9f21be81f" # hung_task: prevent hung smbd from causing a panic
    "858c89f5d6d0" # i2c-bus patch for S9150
    "f810f2e702f1" # Expose tcp sequence numbers to userspace in a vaguely sensible way.
    "9b02fd3fb888" # IR-20330: prevent resetting of SU PCIe bus. Also log all bus resets of other devices.
    "3147509c3eeb" # nvtp1 class zero PCI quirk
    "fa20bc5c0e48" # Skip sync of synchronous nfs mounts
    "3cdb0e5ed4d4" # HACK: ignore IO APIC failures for mlx devices
    "e78fae155ec8" # Remove an msleep from usbhid_open of the 4.19.26 kernel
    "51bb6f496ce7" # IR-52216: Allow mismatched link speeds under lacp bonding mode.
    "d976c4c66536" # Support iommu passthrough specifically for Mellanox devices
    "0f4099d44166" # Add diagnostics to hung_task crashes
    "bf2adbb59e48" # set PACKET_IGNORE_OUTGOING for lldpd to avoid extra copies on the send path
    "070b8f080748" # adjust-default-nfs-readahead-size
    "da6301b86111" # Pull in pinctrl-lewisburg driver changes from FlashArray
    "d7b952654d64" # ixgbe: Stash netdev itself into MDIO bus private field.
    "81ec3fdcc0c4" # Odin DSA support
    "81527c535ef1" # dsa: Use DSA on MV88E6185 rather than EDSA.
    "30f314d4a7a3" # mv88e6xxx/ixgbe: add functions to manipulate SW_FW_SYNC
    "a6b6a17367a1" # Use inband phy instead of hardcoded fixed_props for Marvell DSA
    "41fd3e9ce49e" # allow reading/writing arbitrary MDIO regs from userspace
    "0a48977c177f" # ixgbe: take both PHY semaphores for IXGBE_DEV_ID_X550EM_X_KR
    "72696db2cbfa" # mv88e6xxx: reduce interrupt polling
    "0bca0e968658" # Stop the Odin Marvell switch from initializing in PPU Enabled state
    "f35ceb89c40b" # mv88e6xxx: cancel irq polling prior to freeing irqs
    "275428ad9005" # mv88e6xxx: poll for link state changes
    "97509c6bacfd" # mv88e6xxx-egress-floods-off-if-not-cpu-or-dsa-port
    "ce979045dc65" # Create dpc sysfs interface
    "73aca7714519" # We observe that traffic on the vga device on Thor blades results in spurious packet drops (rx_discards_phy) during times of high network activity. The vga device is as-such unused and this patch disables it for Thor blades. It will no longer show up under lspci/setpci, nor will any driver attach to it.
    "d30b15e136d4" # mm/memory-failure: adding log message during successful offline event
    "119fab11fd37" # memory: add page offline limit for page soft offline
    "9b0d8752d44a" # do not alloc temporary huge pages
    "7e05c076a922" # Add SMI count to EDAC logs.
    "24b387cffead" # edac_dimm_temp
    "f5c3fab1c9ef" # Fetch and log Icelake DIMM temp when logging memory errors
    "8c4efe06be74" # Throttle PCIe AER CE logging
    "6a0cd0ebe0c3" # pci/hotplug: Add debug logging in hotplug ISR
    "da2406e0b3a2" # (HEAD -> v5.15.24_patched) pci/hotplug: missed hotplug interrupt workaround
)

function usage() {
    echo "usage: cmppatch.sh [options] [relpath]"
    echo "        Shows current patch's diff. The relpath is path to file from linux repo"
    exit 1
}

function next_rev() {
    COUNT=$1
    if [ -z "$COUNT" ]; then
        usage
    fi

    START_REV="$(ssh root@irdv-tmenninger git -C /code/linux-5.15.24-incremental-2 rev-parse --short HEAD)"
    for idx in "${!REVISIONS[@]}"; do
        if [[ "${REVISIONS[idx]}" =~ "$START_REV" ]]; then
            REV1=${REVISIONS[idx+COUNT-1]}
            REV2=${REVISIONS[idx+COUNT]}
        fi
    done
    if [ -z "$REV2" ]; then
        echo "FATAL: Could not go to next rev"
        exit 1
    fi
}

function prev_rev() {
    COUNT=$1
    if [ -z "$COUNT" ]; then
        usage
    fi

    START_REV="$(ssh root@irdv-tmenninger git -C /code/linux-5.15.24-incremental-1 rev-parse --short HEAD)"
    for idx in "${!REVISIONS[@]}"; do
        if [[ "${REVISIONS[idx]}" =~ "$START_REV" ]]; then
            REV1=${REVISIONS[idx-COUNT]}
            REV2=${REVISIONS[idx-COUNT+1]}
        fi
    done
    if [ -z "$REV1" ]; then
        echo "FATAL: Could not go to prev rev"
        exit 1
    fi
}

function parse_args() {
    local positional_args=()

    # Options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                ;;
            --inc)
                next_rev 1
                ;;
            --dec)
                prev_rev 1
                ;;
            --next|n)
                shift # to get value
                next_rev $1
                ;;
            --prev|p)
                shift # to get value
                prev_rev $1
                ;;
            --curr|-c)
                NEED_CHECKOUT=false
                ;;
            --clean)
                REV1="${REVISIONS[0]}"
                REV2="${REVISIONS[0]}"
                ;;
            --all)
                REV1="${REVISIONS[${#REVISIONS[@]} - 1]}"
                REV2="${REVISIONS[${#REVISIONS[@]} - 1]}"
                ;;
            --first-dsa)
                REV1="da6301b86111"
                REV2="d7b952654d64"
                ;;
            --last-dsa)
                REV1="275428ad9005"
                REV2="97509c6bacfd"
                ;;
            *)
                positional_args+=("$1")
                ;;
        esac
        shift # past argument
    done

    set -- "${positional_args[@]}"

    RELPATH="$1"
}

function do_checkout() {
    # Check out right revision
    PIDS=()
    ssh root@irdv-tmenninger git -C /code/linux-5.15.24-incremental-1 reset --hard $REV1 &
    PIDS+=("$!")
    ssh root@irdv-tmenninger git -C /code/linux-5.15.24-incremental-2 reset --hard $REV2 &
    PIDS+=("$!")

    # Show what's being used
    wait "${PIDS[@]}"
}

parse_args $@
if $NEED_CHECKOUT; then
    do_checkout
fi

ssh root@irdv-tmenninger git -C /code/linux-5.15.24-incremental-2 log -1

if [ ! -z $RELPATH ]; then
    FILE1="/code/linux-5.15.24-incremental-1/${RELPATH}"
    FILE2="/code/linux-5.15.24-incremental-2/${RELPATH}"
    meld <(ssh root@irdv-tmenninger cat $FILE1) <(ssh root@irdv-tmenninger cat $FILE2)
fi
