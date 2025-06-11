package

    typedef enum logic [4:0] { 
        ADD = 3'b000,
        SUB = 3'b001,
        AND = 3'b010,
        OR  = 3'b011,
        SLT = 3'b101
    } alu_op_t;

    typedef enum logic [6:0] { 
        LW      = 7'b0000011,
        SW      = 7'b0100011,
        R_TYPE  = 7'b0110011,
        B_TYPE  = 7'b1100011,
        I_TYPE  = 7'b0010011,
        J_TYPE  = 7'b1101111   
    } inst_t;

endpackage