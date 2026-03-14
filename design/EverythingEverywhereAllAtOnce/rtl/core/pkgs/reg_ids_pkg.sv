package reg_ids_pkg;

    typedef enum {
        //{datasize, ID}
        AL  = 0,
        AX  = 8,
        EAX = 16,
        MM0 = 24,

        CL  = 1,
        CX  = 9,
        ECX = 17,
        MM1 = 25,

        DL  = 2,
        DX  = 10,
        EDX = 18,
        MM2 = 26,

        BL  = 3,
        BX  = 11,
        EBX = 19,
        MM3 = 27,

        AH  = 4,
        SP  = 12,
        ESP = 20,
        MM4 = 28,

        CH  = 5,
        BP  = 13,
        EBP = 21,
        MM5 = 29,

        DH  = 6,
        SI  = 14,
        ESI = 22,
        MM6 = 30,

        BH  = 7,
        DI  = 15,
        EDI = 23,
        MM7 = 31,

        CS = 32,
        DS = 33,
        SS = 34,
        ES = 35,
        FS = 36,
        GS = 37,

        //tmep reg for rep mov cmp
        ETR = 38

    } reg_ids_e;

endpackage
