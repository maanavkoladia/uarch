package reg_ids_pkg;
    //localparam int NUM_REGS = 39;

    //    typedef enum logic [$clog2(
    //NUM_REGS
    //) - 1:0] {
    //        //{datasize, ID}
    //        AL  = 0,
    //        AX  = 8,
    //        EAX = 16,
    //        MM0 = 24,
    //
    //        CL  = 1,
    //        CX  = 9,
    //        ECX = 17,
    //        MM1 = 25,
    //
    //        DL  = 2,
    //        DX  = 10,
    //        EDX = 18,
    //        MM2 = 26,
    //
    //        BL  = 3,
    //        BX  = 11,
    //        EBX = 19,
    //        MM3 = 27,
    //
    //        AH  = 4,
    //        SP  = 12,
    //        ESP = 20,
    //        MM4 = 28,
    //
    //        CH  = 5,
    //        BP  = 13,
    //        EBP = 21,
    //        MM5 = 29,
    //
    //        DH  = 6,
    //        SI  = 14,
    //        ESI = 22,
    //        MM6 = 30,
    //
    //        BH  = 7,
    //        DI  = 15,
    //        EDI = 23,
    //        MM7 = 31,
    //
    //        CS = 32,
    //        DS = 33,
    //        SS = 34,
    //        ES = 35,
    //        FS = 36,
    //        GS = 37,
    //
    //        //tmep reg for rep mov cmp
    //        ETR = 38,
    //
    //        //error reg, sending here if sometjings wrong, for debugging only
    //        ERROR_REG = 39
    //
    //    } reg_ids_e;


    localparam int NUM_REGS = 23 + 1 + 1 + 1;  //bc etr and error reg
    typedef enum logic [$clog2(NUM_REGS) - 1:0] {
        CS = 0,
        DS = 1,
        SS = 2,
        ES = 3,
        FS = 4,
        GS = 5,
        EXPS = 6,

        EAX = 7,
        EBX = 8,
        ECX = 9,
        EDX = 10,
        ESI = 11,
        EDI = 12,
        ESP = 13,
        EBP = 14,

        MM0 = 15,
        MM1 = 16,
        MM2 = 17,
        MM3 = 18,
        MM4 = 19,
        MM5 = 20,
        MM6 = 21,
        MM7 = 22,

        ETR = 23,
        ERROR_REG = 24,
        NO_REG = 25

    } reg_ids_e;




endpackage
