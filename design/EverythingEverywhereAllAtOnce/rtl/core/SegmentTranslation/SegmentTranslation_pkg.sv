package SegmentTranslation_pkg;

    // Segment Descriptor Structure
    typedef struct packed {
        logic [31:0] base;      // Segment base address
        logic [31:0] limit;     // Segment limit (last valid offset)
    } segment_descriptor_t;


endpackage