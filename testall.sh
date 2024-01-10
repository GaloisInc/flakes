for v in 4_8_8 4_8_9 4_8_10 4_8_11 4_8_12 4_8_13 4_8_14 ; do
    nix build .#z3.v$v;
done;
for v in 2_5 2_6 2_6_2 ; do
    nix build .#yices.v$v;
done;
for v in 2_2 2_3 2_3_1 2_3_2 ; do
    nix build .#stp.v$v;
done
for v in 1_7 1_8 4_1_7 4_1_8 ; do
    nix build .#cvc4.v$v;
done;
for v in 1_0_0 1_0_1 1_0_2 1_0_3 1_0_6 1_0_7 1_0_8 1_0_9 1_1_0 ; do
    nix build .#cvc5.v$v;
done;
for v in 3_1 3_2 3_2_0 3_2_1 3_2_2 ; do
    nix build .#boolector.v$v;
done;
nix build .#abc.v2020_06_22;
nix build .#abc.v2021_12_30;
for v in 0_3_0 ; do
    nix build .#bitwuzla.v$v;
done;
