module Hacl.Test.SHA3

open FStar.HyperStack.All
open FStar.Mul

open LowStar.Buffer

open Lib.IntTypes
open Lib.Buffer
open Lib.PrintBuffer
open Hacl.SHA3

#reset-options "--z3rlimit 50 --max_fuel 0 --max_ifuel 0 --using_facts_from '* -FStar.Seq'"

val test_sha3:
    msg_len:size_t
  -> msg:ilbuffer uint8 msg_len
  -> expected224:ilbuffer uint8 28ul
  -> expected256:ilbuffer uint8 32ul
  -> expected384:ilbuffer uint8 48ul
  -> expected512:ilbuffer uint8 64ul
  -> Stack unit
    (requires fun h ->
      live h msg /\ live h expected224 /\ live h expected256 /\
      live h expected384 /\ live h expected512)
    (ensures  fun h0 r h1 -> True)
let test_sha3 msg_len msg expected224 expected256 expected384 expected512 =
  push_frame();
  assume (v msg_len > 0);
  let msg' = create msg_len (u8 0) in
  copy msg' msg;

  let test224 = create 28ul (u8 0) in
  let test256 = create 32ul (u8 0) in
  let test384 = create 48ul (u8 0) in
  let test512 = create 64ul (u8 0) in
  sha3_224 msg_len msg' test224;
  sha3_256 msg_len msg' test256;
  sha3_384 msg_len msg' test384;
  sha3_512 msg_len msg' test512;

  if not (result_compare_display 28ul test224 expected224) then C.exit 255l;
  if not (result_compare_display 32ul test256 expected256) then C.exit 255l;
  if not (result_compare_display 48ul test384 expected384) then C.exit 255l;
  if not (result_compare_display 64ul test512 expected512) then C.exit 255l;
  pop_frame()

val test_shake128:
     msg_len:size_t
  -> msg:ilbuffer uint8 msg_len
  -> out_len:size_t{size_v out_len > 0}
  -> expected:ilbuffer uint8 out_len
  -> Stack unit
    (requires fun h -> live h msg /\ live h expected)
    (ensures  fun h0 r h1 -> True)
let test_shake128 msg_len msg out_len expected =
  push_frame ();
  assume (v msg_len > 0);
  let msg' = create msg_len (u8 0) in
  copy msg' msg;
  let test = create out_len (u8 0) in
  shake128_hacl msg_len msg' out_len test;
  if not (result_compare_display out_len test expected) then C.exit 255l;
  pop_frame ()

val test_shake256:
     msg_len:size_t
  -> msg:ilbuffer uint8 msg_len
  -> out_len:size_t{size_v out_len > 0}
  -> expected:ilbuffer uint8 out_len
  -> Stack unit
    (requires fun h -> live h msg /\ live h expected)
    (ensures  fun h0 r h1 -> True)
let test_shake256 msg_len msg out_len expected =
  push_frame ();
  assume (v msg_len > 0);
  let msg' = create msg_len (u8 0) in
  copy msg' msg;
  let test = create out_len (u8 0) in
  shake256_hacl msg_len msg' out_len test;
  if not (result_compare_display out_len test expected) then C.exit 255l;
  pop_frame ()

val u8: n:nat{n < 0x100} -> uint8
let u8 n = u8 n

//
// Test1_SHA3
//
let test1_plaintext: b:ilbuffer uint8 0ul{ recallable b } =
  let open Lib.RawIntTypes in
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8 []) in
  assert_norm (List.Tot.length l == 0);
  createL_global l

let test1_expected_sha3_224: b:ilbuffer uint8 28ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x6b; 0x4e; 0x03; 0x42; 0x36; 0x67; 0xdb; 0xb7; 0x3b; 0x6e; 0x15; 0x45; 0x4f; 0x0e; 0xb1; 0xab;
     0xd4; 0x59; 0x7f; 0x9a; 0x1b; 0x07; 0x8e; 0x3f; 0x5b; 0x5a; 0x6b; 0xc7])
  in
  assert_norm (List.Tot.length l == 28);
  createL_global l

let test1_expected_sha3_256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xa7; 0xff; 0xc6; 0xf8; 0xbf; 0x1e; 0xd7; 0x66; 0x51; 0xc1; 0x47; 0x56; 0xa0; 0x61; 0xd6; 0x62;
     0xf5; 0x80; 0xff; 0x4d; 0xe4; 0x3b; 0x49; 0xfa; 0x82; 0xd8; 0x0a; 0x4b; 0x80; 0xf8; 0x43; 0x4a])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

let test1_expected_sha3_384: b:ilbuffer uint8 48ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x0c; 0x63; 0xa7; 0x5b; 0x84; 0x5e; 0x4f; 0x7d; 0x01; 0x10; 0x7d; 0x85; 0x2e; 0x4c; 0x24; 0x85;
     0xc5; 0x1a; 0x50; 0xaa; 0xaa; 0x94; 0xfc; 0x61; 0x99; 0x5e; 0x71; 0xbb; 0xee; 0x98; 0x3a; 0x2a;
     0xc3; 0x71; 0x38; 0x31; 0x26; 0x4a; 0xdb; 0x47; 0xfb; 0x6b; 0xd1; 0xe0; 0x58; 0xd5; 0xf0; 0x04])
  in
  assert_norm (List.Tot.length l == 48);
  createL_global l

let test1_expected_sha3_512: b:ilbuffer uint8 64ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xa6; 0x9f; 0x73; 0xcc; 0xa2; 0x3a; 0x9a; 0xc5; 0xc8; 0xb5; 0x67; 0xdc; 0x18; 0x5a; 0x75; 0x6e;
     0x97; 0xc9; 0x82; 0x16; 0x4f; 0xe2; 0x58; 0x59; 0xe0; 0xd1; 0xdc; 0xc1; 0x47; 0x5c; 0x80; 0xa6;
     0x15; 0xb2; 0x12; 0x3a; 0xf1; 0xf5; 0xf9; 0x4c; 0x11; 0xe3; 0xe9; 0x40; 0x2c; 0x3a; 0xc5; 0x58;
     0xf5; 0x00; 0x19; 0x9d; 0x95; 0xb6; 0xd3; 0xe3; 0x01; 0x75; 0x85; 0x86; 0x28; 0x1d; 0xcd; 0x26])
  in
  assert_norm (List.Tot.length l == 64);
  createL_global l

//
// Test2_SHA3
//
let test2_plaintext: b:ilbuffer uint8 3ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x61; 0x62; 0x63])
  in
  assert_norm (List.Tot.length l == 3);
  createL_global l

let test2_expected_sha3_224: b:ilbuffer uint8 28ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xe6; 0x42; 0x82; 0x4c; 0x3f; 0x8c; 0xf2; 0x4a; 0xd0; 0x92; 0x34; 0xee; 0x7d; 0x3c; 0x76; 0x6f;
     0xc9; 0xa3; 0xa5; 0x16; 0x8d; 0x0c; 0x94; 0xad; 0x73; 0xb4; 0x6f; 0xdf])
  in
  assert_norm (List.Tot.length l == 28);
  createL_global l

let test2_expected_sha3_256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x3a; 0x98; 0x5d; 0xa7; 0x4f; 0xe2; 0x25; 0xb2; 0x04; 0x5c; 0x17; 0x2d; 0x6b; 0xd3; 0x90; 0xbd;
     0x85; 0x5f; 0x08; 0x6e; 0x3e; 0x9d; 0x52; 0x5b; 0x46; 0xbf; 0xe2; 0x45; 0x11; 0x43; 0x15; 0x32])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

let test2_expected_sha3_384: b:ilbuffer uint8 48ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xec; 0x01; 0x49; 0x82; 0x88; 0x51; 0x6f; 0xc9; 0x26; 0x45; 0x9f; 0x58; 0xe2; 0xc6; 0xad; 0x8d;
     0xf9; 0xb4; 0x73; 0xcb; 0x0f; 0xc0; 0x8c; 0x25; 0x96; 0xda; 0x7c; 0xf0; 0xe4; 0x9b; 0xe4; 0xb2;
     0x98; 0xd8; 0x8c; 0xea; 0x92; 0x7a; 0xc7; 0xf5; 0x39; 0xf1; 0xed; 0xf2; 0x28; 0x37; 0x6d; 0x25])
  in
  assert_norm (List.Tot.length l == 48);
  createL_global l

let test2_expected_sha3_512: b:ilbuffer uint8 64ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xb7; 0x51; 0x85; 0x0b; 0x1a; 0x57; 0x16; 0x8a; 0x56; 0x93; 0xcd; 0x92; 0x4b; 0x6b; 0x09; 0x6e;
     0x08; 0xf6; 0x21; 0x82; 0x74; 0x44; 0xf7; 0x0d; 0x88; 0x4f; 0x5d; 0x02; 0x40; 0xd2; 0x71; 0x2e;
     0x10; 0xe1; 0x16; 0xe9; 0x19; 0x2a; 0xf3; 0xc9; 0x1a; 0x7e; 0xc5; 0x76; 0x47; 0xe3; 0x93; 0x40;
     0x57; 0x34; 0x0b; 0x4c; 0xf4; 0x08; 0xd5; 0xa5; 0x65; 0x92; 0xf8; 0x27; 0x4e; 0xec; 0x53; 0xf0])
  in
  assert_norm (List.Tot.length l == 64);
  createL_global l

//
// Test3_SHA3
//
let test3_plaintext: b:ilbuffer uint8 56ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x61; 0x62; 0x63; 0x64; 0x62; 0x63; 0x64; 0x65; 0x63; 0x64; 0x65; 0x66; 0x64; 0x65; 0x66; 0x67;
     0x65; 0x66; 0x67; 0x68; 0x66; 0x67; 0x68; 0x69; 0x67; 0x68; 0x69; 0x6a; 0x68; 0x69; 0x6a; 0x6b;
     0x69; 0x6a; 0x6b; 0x6c; 0x6a; 0x6b; 0x6c; 0x6d; 0x6b; 0x6c; 0x6d; 0x6e; 0x6c; 0x6d; 0x6e; 0x6f;
     0x6d; 0x6e; 0x6f; 0x70; 0x6e; 0x6f; 0x70; 0x71])
  in
  assert_norm (List.Tot.length l == 56);
  createL_global l

let test3_expected_sha3_224: b:ilbuffer uint8 28ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x8a; 0x24; 0x10; 0x8b; 0x15; 0x4a; 0xda; 0x21; 0xc9; 0xfd; 0x55; 0x74; 0x49; 0x44; 0x79; 0xba;
     0x5c; 0x7e; 0x7a; 0xb7; 0x6e; 0xf2; 0x64; 0xea; 0xd0; 0xfc; 0xce; 0x33])
  in
  assert_norm (List.Tot.length l == 28);
  createL_global l

let test3_expected_sha3_256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x41; 0xc0; 0xdb; 0xa2; 0xa9; 0xd6; 0x24; 0x08; 0x49; 0x10; 0x03; 0x76; 0xa8; 0x23; 0x5e; 0x2c;
     0x82; 0xe1; 0xb9; 0x99; 0x8a; 0x99; 0x9e; 0x21; 0xdb; 0x32; 0xdd; 0x97; 0x49; 0x6d; 0x33; 0x76])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

let test3_expected_sha3_384: b:ilbuffer uint8 48ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x99; 0x1c; 0x66; 0x57; 0x55; 0xeb; 0x3a; 0x4b; 0x6b; 0xbd; 0xfb; 0x75; 0xc7; 0x8a; 0x49; 0x2e;
     0x8c; 0x56; 0xa2; 0x2c; 0x5c; 0x4d; 0x7e; 0x42; 0x9b; 0xfd; 0xbc; 0x32; 0xb9; 0xd4; 0xad; 0x5a;
     0xa0; 0x4a; 0x1f; 0x07; 0x6e; 0x62; 0xfe; 0xa1; 0x9e; 0xef; 0x51; 0xac; 0xd0; 0x65; 0x7c; 0x22])
  in
  assert_norm (List.Tot.length l == 48);
  createL_global l

let test3_expected_sha3_512: b:ilbuffer uint8 64ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x04; 0xa3; 0x71; 0xe8; 0x4e; 0xcf; 0xb5; 0xb8; 0xb7; 0x7c; 0xb4; 0x86; 0x10; 0xfc; 0xa8; 0x18;
     0x2d; 0xd4; 0x57; 0xce; 0x6f; 0x32; 0x6a; 0x0f; 0xd3; 0xd7; 0xec; 0x2f; 0x1e; 0x91; 0x63; 0x6d;
     0xee; 0x69; 0x1f; 0xbe; 0x0c; 0x98; 0x53; 0x02; 0xba; 0x1b; 0x0d; 0x8d; 0xc7; 0x8c; 0x08; 0x63;
     0x46; 0xb5; 0x33; 0xb4; 0x9c; 0x03; 0x0d; 0x99; 0xa2; 0x7d; 0xaf; 0x11; 0x39; 0xd6; 0xe7; 0x5e])
  in
  assert_norm (List.Tot.length l == 64);
  createL_global l

//
// Test4_SHA3
//
let test4_plaintext: b:ilbuffer uint8 112ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x61; 0x62; 0x63; 0x64; 0x65; 0x66; 0x67; 0x68; 0x62; 0x63; 0x64; 0x65; 0x66; 0x67; 0x68; 0x69;
     0x63; 0x64; 0x65; 0x66; 0x67; 0x68; 0x69; 0x6a; 0x64; 0x65; 0x66; 0x67; 0x68; 0x69; 0x6a; 0x6b;
     0x65; 0x66; 0x67; 0x68; 0x69; 0x6a; 0x6b; 0x6c; 0x66; 0x67; 0x68; 0x69; 0x6a; 0x6b; 0x6c; 0x6d;
     0x67; 0x68; 0x69; 0x6a; 0x6b; 0x6c; 0x6d; 0x6e; 0x68; 0x69; 0x6a; 0x6b; 0x6c; 0x6d; 0x6e; 0x6f;
     0x69; 0x6a; 0x6b; 0x6c; 0x6d; 0x6e; 0x6f; 0x70; 0x6a; 0x6b; 0x6c; 0x6d; 0x6e; 0x6f; 0x70; 0x71;
     0x6b; 0x6c; 0x6d; 0x6e; 0x6f; 0x70; 0x71; 0x72; 0x6c; 0x6d; 0x6e; 0x6f; 0x70; 0x71; 0x72; 0x73;
     0x6d; 0x6e; 0x6f; 0x70; 0x71; 0x72; 0x73; 0x74; 0x6e; 0x6f; 0x70; 0x71; 0x72; 0x73; 0x74; 0x75])
  in
  assert_norm (List.Tot.length l == 112);
  createL_global l

let test4_expected_sha3_224: b:ilbuffer uint8 28ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x54; 0x3e; 0x68; 0x68; 0xe1; 0x66; 0x6c; 0x1a; 0x64; 0x36; 0x30; 0xdf; 0x77; 0x36; 0x7a; 0xe5;
     0xa6; 0x2a; 0x85; 0x07; 0x0a; 0x51; 0xc1; 0x4c; 0xbf; 0x66; 0x5c; 0xbc])
  in
  assert_norm (List.Tot.length l == 28);
  createL_global l

let test4_expected_sha3_256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x91; 0x6f; 0x60; 0x61; 0xfe; 0x87; 0x97; 0x41; 0xca; 0x64; 0x69; 0xb4; 0x39; 0x71; 0xdf; 0xdb;
     0x28; 0xb1; 0xa3; 0x2d; 0xc3; 0x6c; 0xb3; 0x25; 0x4e; 0x81; 0x2b; 0xe2; 0x7a; 0xad; 0x1d; 0x18])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

let test4_expected_sha3_384: b:ilbuffer uint8 48ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x79; 0x40; 0x7d; 0x3b; 0x59; 0x16; 0xb5; 0x9c; 0x3e; 0x30; 0xb0; 0x98; 0x22; 0x97; 0x47; 0x91;
     0xc3; 0x13; 0xfb; 0x9e; 0xcc; 0x84; 0x9e; 0x40; 0x6f; 0x23; 0x59; 0x2d; 0x04; 0xf6; 0x25; 0xdc;
     0x8c; 0x70; 0x9b; 0x98; 0xb4; 0x3b; 0x38; 0x52; 0xb3; 0x37; 0x21; 0x61; 0x79; 0xaa; 0x7f; 0xc7])
  in
  assert_norm (List.Tot.length l == 48);
  createL_global l

let test4_expected_sha3_512: b:ilbuffer uint8 64ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xaf; 0xeb; 0xb2; 0xef; 0x54; 0x2e; 0x65; 0x79; 0xc5; 0x0c; 0xad; 0x06; 0xd2; 0xe5; 0x78; 0xf9;
     0xf8; 0xdd; 0x68; 0x81; 0xd7; 0xdc; 0x82; 0x4d; 0x26; 0x36; 0x0f; 0xee; 0xbf; 0x18; 0xa4; 0xfa;
     0x73; 0xe3; 0x26; 0x11; 0x22; 0x94; 0x8e; 0xfc; 0xfd; 0x49; 0x2e; 0x74; 0xe8; 0x2e; 0x21; 0x89;
     0xed; 0x0f; 0xb4; 0x40; 0xd1; 0x87; 0xf3; 0x82; 0x27; 0x0c; 0xb4; 0x55; 0xf2; 0x1d; 0xd1; 0x85])
  in
  assert_norm (List.Tot.length l == 64);
  createL_global l

//
// Test5_SHAKE128
//
let test5_plaintext_shake128: b:ilbuffer uint8 0ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 = normalize_term (List.Tot.map u8 []) in
  assert_norm (List.Tot.length l == 0);
  createL_global l

let test5_expected_shake128: b:ilbuffer uint8 16ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x7f; 0x9c; 0x2b; 0xa4; 0xe8; 0x8f; 0x82; 0x7d; 0x61; 0x60; 0x45; 0x50; 0x76; 0x05; 0x85; 0x3e])
  in
  assert_norm (List.Tot.length l == 16);
  createL_global l

//
// Test6_SHAKE128
//
let test6_plaintext_shake128: b:ilbuffer uint8 14ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x52; 0x97; 0x7e; 0x53; 0x2b; 0xcc; 0xdb; 0x89; 0xdf; 0xef; 0xf7; 0xe9; 0xe4; 0xad]) in
  assert_norm (List.Tot.length l == 14);
  createL_global l

let test6_expected_shake128: b:ilbuffer uint8 16ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xfb; 0xfb; 0xa5; 0xc1; 0xe1; 0x79; 0xdf; 0x14; 0x69; 0xfc; 0xc8; 0x58; 0x8a; 0xe5; 0xd2; 0xcc])
  in
  assert_norm (List.Tot.length l == 16);
  createL_global l

//
// Test7_SHAKE128
//
let test7_plaintext_shake128: b:ilbuffer uint8 34ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x4a; 0x20; 0x6a; 0x5b; 0x8a; 0xa3; 0x58; 0x6c; 0x06; 0x67; 0xa4; 0x00; 0x20; 0xd6; 0x5f; 0xf5;
     0x11; 0xd5; 0x2b; 0x73; 0x2e; 0xf7; 0xa0; 0xc5; 0x69; 0xf1; 0xee; 0x68; 0x1a; 0x4f; 0xc3; 0x62;
     0x00; 0x65])
  in
  assert_norm (List.Tot.length l == 34);
  createL_global l

let test7_expected_shake128: b:ilbuffer uint8 16ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x7b; 0xb4; 0x33; 0x75; 0x2b; 0x98; 0xf9; 0x15; 0xbe; 0x51; 0x82; 0xbc; 0x1f; 0x09; 0x66; 0x48])
  in
  assert_norm (List.Tot.length l == 16);
  createL_global l

//
// Test8_SHAKE128
//
let test8_plaintext_shake128: b:ilbuffer uint8 83ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x24; 0x69; 0xf1; 0x01; 0xc9; 0xb4; 0x99; 0xa9; 0x30; 0xa9; 0x7e; 0xf1; 0xb3; 0x46; 0x73; 0xec;
     0x74; 0x39; 0x3f; 0xd9; 0xfa; 0xf6; 0x58; 0xe3; 0x1f; 0x06; 0xee; 0x0b; 0x29; 0xa2; 0x2b; 0x62;
     0x37; 0x80; 0xba; 0x7b; 0xdf; 0xed; 0x86; 0x20; 0x15; 0x1c; 0xc4; 0x44; 0x4e; 0xbe; 0x33; 0x39;
     0xe6; 0xd2; 0xa2; 0x23; 0xbf; 0xbf; 0xb4; 0xad; 0x2c; 0xa0; 0xe0; 0xfa; 0x0d; 0xdf; 0xbb; 0xdf;
     0x3b; 0x05; 0x7a; 0x4f; 0x26; 0xd0; 0xb2; 0x16; 0xbc; 0x87; 0x63; 0xca; 0x8d; 0x8a; 0x35; 0xff;
     0x2d; 0x2d; 0x01])
  in
  assert_norm (List.Tot.length l == 83);
  createL_global l

let test8_expected_shake128: b:ilbuffer uint8 16ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x00; 0xff; 0x5e; 0xf0; 0xcd; 0x7f; 0x8f; 0x90; 0xad; 0x94; 0xb7; 0x97; 0xe9; 0xd4; 0xdd; 0x30])
  in
  assert_norm (List.Tot.length l == 16);
  createL_global l

//
// Test9_SHAKE256
//
let test9_plaintext_shake256: b:ilbuffer uint8 0ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 = normalize_term (List.Tot.map u8 []) in
  assert_norm (List.Tot.length l == 0);
  createL_global l

let test9_expected_shake256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x46; 0xb9; 0xdd; 0x2b; 0x0b; 0xa8; 0x8d; 0x13; 0x23; 0x3b; 0x3f; 0xeb; 0x74; 0x3e; 0xeb; 0x24;
     0x3f; 0xcd; 0x52; 0xea; 0x62; 0xb8; 0x1b; 0x82; 0xb5; 0x0c; 0x27; 0x64; 0x6e; 0xd5; 0x76; 0x2f])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

//
// Test10_SHAKE256
//
let test10_plaintext_shake256: b:ilbuffer uint8 17ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xf9; 0xda; 0x78; 0xc8; 0x90; 0x84; 0x70; 0x40; 0x45; 0x4b; 0xa6; 0x42; 0x98; 0x82; 0xb0; 0x54;
     0x09])
  in
  assert_norm (List.Tot.length l == 17);
  createL_global l

let test10_expected_shake256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xa8; 0x49; 0x83; 0xc9; 0xfe; 0x75; 0xad; 0x0d; 0xe1; 0x9e; 0x2c; 0x84; 0x20; 0xa7; 0xea; 0x85;
     0xb2; 0x51; 0x02; 0x19; 0x56; 0x14; 0xdf; 0xa5; 0x34; 0x7d; 0xe6; 0x0a; 0x1c; 0xe1; 0x3b; 0x60])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

//
// Test11_SHAKE256
//
let test11_plaintext_shake256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xef; 0x89; 0x6c; 0xdc; 0xb3; 0x63; 0xa6; 0x15; 0x91; 0x78; 0xa1; 0xbb; 0x1c; 0x99; 0x39; 0x46;
     0xc5; 0x04; 0x02; 0x09; 0x5c; 0xda; 0xea; 0x4f; 0xd4; 0xd4; 0x19; 0xaa; 0x47; 0x32; 0x1c; 0x88])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

let test11_expected_shake256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x7a; 0xbb; 0xa4; 0xe8; 0xb8; 0xdd; 0x76; 0x6b; 0xba; 0xbe; 0x98; 0xf8; 0xf1; 0x69; 0xcb; 0x62;
     0x08; 0x67; 0x4d; 0xe1; 0x9a; 0x51; 0xd7; 0x3c; 0x92; 0xb7; 0xdc; 0x04; 0xa4; 0xb5; 0xee; 0x3d])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

//
// Test12_SHAKE256
//
let test12_plaintext_shake256: b:ilbuffer uint8 78ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0xde; 0x70; 0x1f; 0x10; 0xad; 0x39; 0x61; 0xb0; 0xda; 0xcc; 0x96; 0x87; 0x3a; 0x3c; 0xd5; 0x58;
     0x55; 0x81; 0x88; 0xff; 0x69; 0x6d; 0x85; 0x01; 0xb2; 0xe2; 0x7b; 0x67; 0xe9; 0x41; 0x90; 0xcd;
     0x0b; 0x25; 0x48; 0xb6; 0x5b; 0x52; 0xa9; 0x22; 0xaa; 0xe8; 0x9d; 0x63; 0xd6; 0xdd; 0x97; 0x2c;
     0x91; 0xa9; 0x79; 0xeb; 0x63; 0x43; 0xb6; 0x58; 0xf2; 0x4d; 0xb3; 0x4e; 0x82; 0x8b; 0x74; 0xdb;
     0xb8; 0x9a; 0x74; 0x93; 0xa3; 0xdf; 0xd4; 0x29; 0xfd; 0xbd; 0xb8; 0x40; 0xad; 0x0b])
  in
  assert_norm (List.Tot.length l == 78);
  createL_global l

let test12_expected_shake256: b:ilbuffer uint8 32ul{ recallable b } =
  [@ inline_let]
  let l:list uint8 =
    normalize_term (List.Tot.map u8
    [0x64; 0x2f; 0x3f; 0x23; 0x5a; 0xc7; 0xe3; 0xd4; 0x34; 0x06; 0x3b; 0x5f; 0xc9; 0x21; 0x5f; 0xc3;
     0xf0; 0xe5; 0x91; 0xe2; 0xe7; 0xfd; 0x17; 0x66; 0x8d; 0x1a; 0x0c; 0x87; 0x46; 0x87; 0x35; 0xc2])
  in
  assert_norm (List.Tot.length l == 32);
  createL_global l

val main: unit -> St C.exit_code
let main () =
  C.String.print (C.String.of_literal "\nTEST 1. SHA3\n");
  recall test1_expected_sha3_224;
  recall test1_expected_sha3_256;
  recall test1_expected_sha3_384;
  recall test1_expected_sha3_512;
  recall test1_plaintext;
  test_sha3 0ul test1_plaintext test1_expected_sha3_224 test1_expected_sha3_256 test1_expected_sha3_384 test1_expected_sha3_512;

  C.String.print (C.String.of_literal "\nTEST 2. SHA3\n");
  recall test2_expected_sha3_224;
  recall test2_expected_sha3_256;
  recall test2_expected_sha3_384;
  recall test2_expected_sha3_512;
  recall test2_plaintext;
  test_sha3 3ul test2_plaintext test2_expected_sha3_224 test2_expected_sha3_256 test2_expected_sha3_384 test2_expected_sha3_512;

  C.String.print (C.String.of_literal "\nTEST 3. SHA3\n");
  recall test3_expected_sha3_224;
  recall test3_expected_sha3_256;
  recall test3_expected_sha3_384;
  recall test3_expected_sha3_512;
  recall test3_plaintext;
  test_sha3 56ul test3_plaintext test3_expected_sha3_224 test3_expected_sha3_256 test3_expected_sha3_384 test3_expected_sha3_512;

  C.String.print (C.String.of_literal "\nTEST 4. SHA3\n");
  recall test4_expected_sha3_224;
  recall test4_expected_sha3_256;
  recall test4_expected_sha3_384;
  recall test4_expected_sha3_512;
  recall test4_plaintext;
  test_sha3 112ul test4_plaintext test4_expected_sha3_224 test4_expected_sha3_256 test4_expected_sha3_384 test4_expected_sha3_512;

  C.String.print (C.String.of_literal "\nTEST 5. SHAKE128\n");
  recall test5_plaintext_shake128;
  recall test5_expected_shake128;
  test_shake128 0ul test5_plaintext_shake128 16ul test5_expected_shake128;

  C.String.print (C.String.of_literal "\nTEST 6. SHAKE128\n");
  recall test6_plaintext_shake128;
  recall test6_expected_shake128;
  test_shake128 14ul test6_plaintext_shake128 16ul test6_expected_shake128;

  C.String.print (C.String.of_literal "\nTEST 7. SHAKE128\n");
  recall test7_plaintext_shake128;
  recall test7_expected_shake128;
  test_shake128 34ul test7_plaintext_shake128 16ul test7_expected_shake128;

  C.String.print (C.String.of_literal "\nTEST 8. SHAKE128\n");
  recall test8_plaintext_shake128;
  recall test8_expected_shake128;
  test_shake128 83ul test8_plaintext_shake128 16ul test8_expected_shake128;

  C.String.print (C.String.of_literal "\nTEST 9. SHAKE256\n");
  recall test9_plaintext_shake256;
  recall test9_expected_shake256;
  test_shake256 0ul test9_plaintext_shake256 32ul test9_expected_shake256;

  C.String.print (C.String.of_literal "\nTEST 10. SHAKE256\n");
  recall test10_plaintext_shake256;
  recall test10_expected_shake256;
  test_shake256 17ul test10_plaintext_shake256 32ul test10_expected_shake256;

  C.String.print (C.String.of_literal "\nTEST 11. SHAKE256\n");
  recall test11_plaintext_shake256;
  recall test11_expected_shake256;
  test_shake256 32ul test11_plaintext_shake256 32ul test11_expected_shake256;

  C.String.print (C.String.of_literal "\nTEST 12. SHAKE256\n");
  recall test12_plaintext_shake256;
  recall test12_expected_shake256;
  test_shake256 78ul test12_plaintext_shake256 32ul test12_expected_shake256;

  C.EXIT_SUCCESS
