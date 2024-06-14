package speedup
import "core:testing"
import "core:fmt"
StringOrError :: union {
    string,
    ParseError
}

TestCase :: struct {
	old: string,
    new: string,
    speedup: StringOrError,
}
TestCase_to_args :: proc(test_case: TestCase) -> [3]string {
    return [3]string{"program name", test_case.old, test_case.new}
}


@(test)
run_valid_tests :: proc(t: ^testing.T){
    valid_test_cases := [?]TestCase{
        {old="20", new="15", speedup="25.00%"},
        {old="10", new="10", speedup="0.00%"},
        {old="10", new="0", speedup="100.00%"},
        {old="10", new="9.99", speedup="0.10%"},
        {old="100", new="50", speedup="50.00%"},
        {old="17.67", new="11.42", speedup="35.37%"},
        {old="0.5", new="0.25", speedup="50.00%"},
        {old="1000", new="500", speedup="50.00%"},
        {old="15", new="20", speedup="-33.33%"},
    }
    for test_case in valid_test_cases {
        args := TestCase_to_args(test_case)
        old_time, new_time, err := parse_inputs(args[:])
        fmt.println(err)
        if err != .None {
            testing.expect(t, err == test_case.speedup)
        }
        speedup := calculate_speedup(old_time, new_time)
        defer delete(speedup)
        testing.expect(t, speedup == test_case.speedup)
    }
}

@(test)
run_invalid_tests :: proc(t: ^testing.T){
    
    invalid_test_cases := [?]TestCase{
        {old="abc", new="20", speedup=.InvalidInput_Old},
        {old="50", new="xyz", speedup=.InvalidInput_New},
        {old="", new="30", speedup=.InvalidInput_Old},
        {old="nil", new="30", speedup=.InvalidInput_Old},
        {old="true", new="10", speedup=.InvalidInput_Old},
        {old="0", new="5", speedup=.Undefined},
    }
    for test_case in invalid_test_cases {
        args := TestCase_to_args(test_case)
        old_time, new_time, err := parse_inputs(args[:])
        if err != .None {
            testing.expect(t, err == test_case.speedup)
        }
        speedup := calculate_speedup(old_time, new_time)
        defer delete(speedup)
    }
}