-module(bitstr).

-export([f11/1, f12/3, f13/3, f13a/3,
         f21/1, f22/2, f23/2, f24/2, f24a/2, f25/2, f26/2, f27/2,
         f31/2, f32/3, f33/4, f34/2, f35/1, f36/1, f37/1,
         fbit_sz/1, fbyte_sz/1,
         fbsl/2, fbsl_big/1, fbsr/2, fbsr_big/1, fbnot/1, fbnot_big/1,
         fband/2, fband2/2, fband_neg/2, fband3/2, fband2_neg/2,
         fbxor/2, fbxor2/2, fbxor3/2, fbxor_neg/2, fbxor2_neg/2, fbxor3_neg/2,
         fbor/2, fbor2/2, fbor3/2, fbor_neg/2, fbor2_neg/2,
         enc_type_mismatch/2]).

%%---------------------------------
%% Construct bitstrings.
%%---------------------------------

-spec f11(integer()) -> ok.
f11(X) ->
  case <<X:7>> =:= <<42:7>> of
    true -> error(not_ok);
    false -> ok
  end.

-spec f12(integer(), integer(), integer()) -> ok.
f12(X, Y, Z) ->
  case <<X:2, Y:3, Z:3>> =:= <<42>> of
    true -> error(not_ok);
    false -> ok
  end.

%% This one takes some time (just to demonstrate the scalability problem
%% with the current implementation).  This one should fail in (at least)
%% three different ways: at the error point, with a negative Y and with
%% a negative Z value.
-spec f13(integer(), integer(), integer()) -> ok.
f13(X, Y, Z) ->
  case <<5:3, X:Y, 2:Z>> of
    <<186>> -> error(not_ok);
    _ -> ok
  end.

%% Variation of the above where the two size arguments have appropriate
%% (correct) declarations and hence it fails only at the error point.
-spec f13a(integer(), non_neg_integer(), non_neg_integer()) -> ok.
f13a(X, Y, Z) ->
  case <<5:3, X:Y, 2:Z>> of
    <<186>> -> error(not_ok);
    _ -> ok
  end.

%%---------------------------------
%% Match against a constant value.
%%---------------------------------

-spec f21(bitstring()) -> ok.
f21(X) ->
  case X of
    <<42:15>> -> error(not_ok);
    _ -> ok
  end.

-spec f22(bitstring(), integer()) -> ok.
f22(X, Y) ->
  case X of
    <<42:Y>> -> error(not_ok);
    _ -> ok
  end.

-spec f23(integer(), integer()) -> ok.
f23(X, Y) ->
  case <<X:5>> of
    <<9:Y>> -> error(not_ok);
    _ -> ok
  end.

-spec f24(<<_:6>>, integer()) -> ok.
f24(X, Y) ->
  case X of
    <<42:Y>> -> error(not_ok);
    _ -> ok
  end.

-spec f24a(bitstring(), neg_integer()) -> ok.
f24a(X, Y) ->
  case X of
    <<42>> when Y =:= -3 -> <<42:Y>>;
    <<42:Y>> -> error(unreachable_bug);
    _ -> ok
  end.

-spec f25(<<_:_*3>>, integer()) -> ok.
f25(X, Y) ->
  case X of
    <<42:Y>> -> error(not_ok);
    _ -> ok
  end.

-spec f26(<<_:6, _:_*2>>, integer()) -> ok.
f26(X, Y) ->
  case X of
    <<42:Y>> -> error(not_ok);
    _ -> ok
  end.

-spec f27(<<_:4>>, integer()) -> ok.
f27(X, Y) ->
  case X of
    <<42:Y>> -> error(not_ok);
    _ -> ok
  end.

%%---------------------------------
%% Match and binding variables.
%%---------------------------------

-spec f31(bitstring(), integer()) -> ok.
f31(X, Y) ->
  case X of
    <<Y:4>> -> error(not_ok);
    _ -> ok
  end.

-spec f32(bitstring(), integer(), integer()) -> ok.
f32(X, Y, Z) ->
  case X of
    <<2:3, Y:Z, 3>> -> error(not_ok);
    _ -> ok
  end.

-spec f33(bitstring(), integer(), integer(), bitstring()) -> ok.
f33(X, Y, K, Z) ->
  case Z of
    <<>> -> ok;
    _ ->
      case X of
        <<K:Y, Z/bits>> -> error(not_ok);
        _ -> ok
      end
  end.

-spec f34(<<_:_*3>>, integer()) -> ok.
f34(X, Y) ->
  case X of
    <<Y:4>> -> error(not_ok);
    _ -> ok
  end.

-spec f35(<<_:6, _:_*7>>) -> ok.
f35(X) ->
  case X of
    <<_:42>> -> error(not_ok);
    _ -> ok
  end.

-spec f36(<<_:6, _:_*7>> | <<_:_*4>>) -> ok.
f36(X) ->
  case X of
    <<_:42>> -> error(not_ok);
    _ -> ok
  end.

-spec f37(<<_:6, _:_*7>> | <<_:_*4>> | <<_:_*6>>) -> ok.
f37(X) ->
  case X of
    <<_:42>> -> error(not_ok);
    _ -> ok
  end.

-spec enc_type_mismatch(any(), integer()) -> ok.
enc_type_mismatch(V, Sz) ->
  case <<V:Sz>> of
    <<42>> -> error(bug);
    _ -> ok
  end.

%%---------------------------------
%% Bitstring size functions.
%%---------------------------------

-spec fbit_sz(bitstring()) -> ok.
fbit_sz(Bits) ->
  case bit_size(Bits) of
    Sz when Sz < 4 -> ok
  end.

-spec fbyte_sz(bitstring()) -> ok.
fbyte_sz(Bits) ->
  case byte_size(Bits) of
    Sz when Sz < 2 -> ok
  end.

%%---------------------------------
%% Binary operators.
%%---------------------------------

-spec fbsl(integer(), integer()) -> ok.
fbsl(X, Y) ->
  case X bsl Y of
    42 -> error(bug);
    _ -> ok
  end.

-spec fbsl_big(integer()) -> ok.
fbsl_big(X) ->
  M = 123456789012345,
  L = 123456789012345678901234567890,
  XL = 1234567890123456789012345678901234567890123456789012345678901234567890,
  case X bsl 4 of
    Y when Y > M, Y < L -> error(bug1);
    Y when Y > L, Y < XL -> error(bug2);
    Y when Y > XL -> error(bug3);
    _ -> ok
  end.

-spec fbsr(integer(), integer()) -> ok.
fbsr(X, Y) ->
  case X bsr Y of
    42 -> error(bug);
    _ -> ok
  end.

-spec fbsr_big(integer()) -> ok.
fbsr_big(X) ->
  M = 123456789012345,
  L = 123456789012345678901234567890,
  XL = 1234567890123456789012345678901234567890123456789012345678901234567890,
  case X bsr 4 of
    Y when Y > M, Y < L -> error(bug1);
    Y when Y > L, Y < XL -> error(bug2);
    Y when Y > XL -> error(bug3);
    _ -> ok
  end.

-spec fbnot(integer()) -> ok.
fbnot(X) ->
  case bnot X of
    42 -> error(bug);
    _ -> ok
  end.

-spec fbnot_big(integer()) -> ok.
fbnot_big(X) ->
  M = 123456789012345,
  L = 123456789012345678901234567890,
  XL = 1234567890123456789012345678901234567890123456789012345678901234567890,
  case bnot X of
    Y when Y > M, Y < L -> error(bug1);
    Y when Y > L, Y < XL -> error(bug2);
    Y when Y > XL -> error(bug3);
    _ -> ok
  end.

-spec fband(integer(), integer()) -> ok.
fband(X, Y) ->
  case X band Y of
    42 -> error(bug);
    _ -> ok
  end.

-spec fband2(integer(), integer()) -> ok.
fband2(X, Y) ->
  case X band Y of
    1267650600228229401496703205376 -> error(bug); % 2^100
    _ -> ok
  end.

-spec fband_neg(integer(), integer()) -> ok.
fband_neg(X, Y) ->
  case X band Y of
    -42 -> error(bug);
    _ -> ok
  end.

-spec fband3(integer(), integer()) -> ok.
fband3(X, Y) ->
  case (X + Y) band (X - Y) of
    1208425819634629144706176 -> error(bug);
    _ -> ok
  end.

-spec fband2_neg(integer(), integer()) -> ok.
fband2_neg(X, Y) ->
  case X band Y of
    -1299341865233935136534120785510400 -> error(bug); % - 2^110 - 2^100
    _ -> ok
  end.

-spec fbxor(integer(), integer()) -> ok.
fbxor(X, Y) ->
  case X bxor Y of
    42 -> error(bug);
    _ -> ok
  end.

-spec fbxor2(integer(), integer()) -> ok.
fbxor2(X, Y) ->
  case X bxor Y of
    546546546546546 -> error(bug);
    _ -> ok
  end.

-spec fbxor3(integer(), integer()) -> ok.
fbxor3(X, Y) ->
  case X bxor Y of
    1321678065467065468706546708964 -> error(bug);
    _ -> ok
  end.

-spec fbxor_neg(integer(), integer()) -> ok.
fbxor_neg(X, Y) ->
  case X bxor Y of
    -42 -> error(bug);
    _ -> ok
  end.

-spec fbxor2_neg(integer(), integer()) -> ok.
fbxor2_neg(X, Y) ->
  case X bxor Y of
    -546546546546546 -> error(bug);
    _ -> ok
  end.

-spec fbxor3_neg(integer(), integer()) -> ok.
fbxor3_neg(X, Y) ->
  case X bxor Y of
    -1321678065467065468706546708964 -> error(bug);
    _ -> ok
  end.

-spec fbor(integer(), integer()) -> ok.
fbor(X, Y) ->
  case X bor Y of
    42 -> error(bug);
    _ -> ok
  end.

-spec fbor2(integer(), integer()) -> ok.
fbor2(X, Y) ->
  case X bor Y of
    654654621354008904 -> error(bug);
    _ -> ok
  end.

-spec fbor3(integer(), integer()) -> ok.
fbor3(X, Y) ->
  case X bor Y of
    132167806349873198573065468706546708964 -> error(bug);
    _ -> ok
  end.

-spec fbor_neg(integer(), integer()) -> ok.
fbor_neg(X, Y) ->
  case X bor Y of
    -3 -> error(bug);
    _ -> ok
  end.

-spec fbor2_neg(integer(), integer()) -> ok.
fbor2_neg(X, Y) ->
  case X bor Y of
    -2581098572349081592347598712638 -> error(bug);
    _ -> ok
  end.
