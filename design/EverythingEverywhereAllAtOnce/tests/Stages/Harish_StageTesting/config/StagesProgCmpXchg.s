.org 0x1000
.code
.global _start

_start:
    # ----------------------------
    # Setup test memory
    # ----------------------------
    movl $0x2000, %edi          # base address

    movl $0xAAAAAAA0, 0(%edi)   # mem[0x2000] = AAAAAAA0
    movl $0xCCCCCCC0, 4(%edi)   # mem[0x2004] = CCCCCCC0

    # ----------------------------
    # TEST 1: Register CMPXCHG (SUCCESS)
    # ----------------------------
    movl $0x11111111, %ebx      # dest
    movl $0x22222222, %ecx      # src
    movl $0x11111111, %eax      # expected (matches dest)

    cmpxchgl %ecx, %ebx         # should succeed
                                 # EBX = ECX
                                 # ZF = 1
                                 # EAX unchanged

    # ----------------------------
    # TEST 2: Register CMPXCHG (FAILURE)
    # ----------------------------
    movl $0x33333333, %ebx      # dest
    movl $0x44444444, %ecx      # src
    movl $0x55555555, %eax      # expected (does NOT match)

    cmpxchgl %ecx, %ebx         # should fail
                                 # EAX = old EBX (0x33333333)
                                 # EBX unchanged
                                 # ZF = 0

    # ----------------------------
    # TEST 3: Memory CMPXCHG (SUCCESS)
    # ----------------------------
    movl $0xAAAAAAA0, %eax      # expected matches mem
    movl $0xBBBBBBB0, %edx      # src

    cmpxchgl %edx, 0(%edi)      # should succeed
                                 # mem[0x2000] = EDX
                                 # ZF = 1
                                 # EAX unchanged

    # ----------------------------
    # TEST 4: Memory CMPXCHG (FAILURE)
    # ----------------------------
    movl $0x12345678, %eax      # wrong expected
    movl $0xDDDDDDD0, %edx      # src

    cmpxchgl %edx, 4(%edi)      # should fail
                                 # EAX = old mem[0x2004] (0xCCCCCCC0)
                                 # mem unchanged
                                 # ZF = 0

    # ----------------------------
    # Optional: Chain test (checks EAX forwarding)
    # ----------------------------
    # After failure above, EAX == old mem value
    # Now use it immediately for a success
    movl $0xEEEEEEE0, %edx

    cmpxchgl %edx, 4(%edi)      # should now succeed if EAX matched

    # ----------------------------
    # Done
    # ----------------------------
    hlt