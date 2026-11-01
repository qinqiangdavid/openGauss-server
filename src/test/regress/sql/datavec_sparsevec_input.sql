-- sparsevec input: error DETAIL must name the same type as the error message
SELECT '{1:1,3:2}/3'::sparsevec;
SELECT '[1,1]'::sparsevec;
SELECT l2_norm('[1,1]');
