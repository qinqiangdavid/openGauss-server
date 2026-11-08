--
-- Regression test for to_number() integer-digit overflow (A_FORMAT / Oracle).
--
-- Oracle requires that the number of digits to the left of the decimal point in
-- the input not exceed the number of integer digit positions (9/0) in the format
-- mask; otherwise it raises an error. openGauss used to silently drop or
-- mis-parse the surplus leading digits and return a wrong value:
--   to_number('12345', '999')      silently returned 123
--   to_number('12345.67', '999.99') silently returned a wrong value
--
-- The regression database is created with DBCOMPATIBILITY='A' (A_FORMAT), so the
-- Oracle behavior is exercised without any extra setup. This test uses anonymous
-- blocks with an exception handler so the output is deterministic (only NOTICE
-- lines, no column padding): every "rejected" NOTICE means the overflow was
-- correctly turned into an error.

-- Inputs whose integer digits fit the mask must keep returning the right value.
BEGIN
    IF to_number('123', '999') = 123
       AND to_number('5', '999') = 5
       AND to_number('999', '999') = 999
       AND to_number('12.5', '99.9') = 12.5
       AND to_number('0', '99.99') = 0 THEN
        RAISE NOTICE 'valid-fit inputs: ok';
    ELSE
        RAISE NOTICE 'valid-fit inputs: WRONG';
    END IF;
END;
/

-- Surplus integer digits must now raise an error instead of a wrong value.
BEGIN
    PERFORM to_number('12345', '999');
    RAISE NOTICE 'FAIL 12345/999: not rejected';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'PASS 12345/999: rejected (%)', SQLERRM;
END;
/

BEGIN
    PERFORM to_number('1000', '9');
    RAISE NOTICE 'FAIL 1000/9: not rejected';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'PASS 1000/9: rejected (%)', SQLERRM;
END;
/

BEGIN
    PERFORM to_number('12345.67', '999.99');
    RAISE NOTICE 'FAIL 12345.67/999.99: not rejected';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'PASS 12345.67/999.99: rejected (%)', SQLERRM;
END;
/

BEGIN
    PERFORM to_number('123456', '99999');
    RAISE NOTICE 'FAIL 123456/99999: not rejected';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'PASS 123456/99999: rejected (%)', SQLERRM;
END;
/
