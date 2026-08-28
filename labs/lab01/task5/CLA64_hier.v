// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // TODO: your hierarchical design goes here.
wire p0, p1, p2, p3;
    wire g0, g1, g2, g3;
    wire c1, c2, c3, c4;

    wire c1_t0;
    wire c2_t0, c2_t1;
    wire c3_t0, c3_t1, c3_t2;
    wire c4_t0, c4_t1, c4_t2, c4_t3;

    // Bit-level Generate and Propagate
    xor #(2) (p0, a[0], b[0]);
    xor #(2) (p1, a[1], b[1]);
    xor #(2) (p2, a[2], b[2]);
    xor #(2) (p3, a[3], b[3]);

    and #(2) (g0, a[0], b[0]);
    and #(2) (g1, a[1], b[1]);
    and #(2) (g2, a[2], b[2]);
    and #(2) (g3, a[3], b[3]);

    // Internal carry generation
    and #(2) (c1_t0, p0, cin);
    or  #(2) (c1, g0, c1_t0);

    and #(2) (c2_t0, p1, g0);
    and #(2) (c2_t1, p1, p0, cin);
    or  #(2) (c2, g1, c2_t0, c2_t1);

    and #(2) (c3_t0, p2, g1);
    and #(2) (c3_t1, p2, p1, g0);
    and #(2) (c3_t2, p2, p1, p0, cin);
    or  #(2) (c3, g2, c3_t0, c3_t1, c3_t2);

    and #(2) (c4_t0, p3, g2);
    and #(2) (c4_t1, p3, p2, g1);
    and #(2) (c4_t2, p3, p2, p1, g0);
    and #(2) (c4_t3, p3, p2, p1, p0, cin);
    or  #(2) (c4, g3, c4_t0, c4_t1, c4_t2, c4_t3);

    assign cout = c4;

    // Block-level Propagate and Generate
    and #(2) (P_blk, p3, p2, p1, p0);
    
    wire g_t0, g_t1, g_t2;
    and #(2) (g_t0, p3, g2);
    and #(2) (g_t1, p3, p2, g1);
    and #(2) (g_t2, p3, p2, p1, g0);
    or  #(2) (G_blk, g3, g_t0, g_t1, g_t2);

    // Sum calculation
    xor #(2) (sum[0], p0, cin);
    xor #(2) (sum[1], p1, c1);
    xor #(2) (sum[2], p2, c2);
    xor #(2) (sum[3], p3, c3);
endmodule
