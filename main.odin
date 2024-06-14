package speedup

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:mem"

ParseError :: enum {
    None,
    InvalidInput_Old,
    InvalidInput_New,
    Undefined,
    NumArguments,
}

parse_inputs :: proc(args: []string) -> (old_time, new_time: f64, err: ParseError){
    if len(args) != 3  {
        return -1, -1, .NumArguments 
    }
    success: bool
    old_time, success = strconv.parse_f64(args[1])
    if !success {
        return -1, -1, .InvalidInput_Old
        }
    if old_time == 0 {
        return -1, -1, .Undefined
    }
    new_time, success = strconv.parse_f64(args[2])
    if !success {
        return -1, -1, .InvalidInput_New
    }
    return old_time, new_time, .None
}

calculate_speedup :: proc(old_time, new_time: f64)-> string {
    return fmt.aprintf("{0:.2f}%%", 100 * (old_time - new_time) / old_time)
}

main :: proc(){
    old_time, new_time, err := parse_inputs(os.args)
    if err != .None {
        fmt.println("Usage: speedup <old time> <new time>")
        #partial switch err {
            case .Undefined:
                fmt.println("<old time> is 0. Speeup is undefined")
            case .InvalidInput_Old:
                fmt.printfln("Invalid <old time>: {0}", os.args[1])
            case .InvalidInput_New:
                fmt.printfln("Invalid <new time>: {0}", os.args[2])
            case .NumArguments:
                fmt.printfln("Expected 3 arguments. Got {0} argument(s)", len(os.args))
        }
        os.exit(1)
    }
    speedup := calculate_speedup(old_time, new_time)   
    fmt.println(speedup)
    delete(speedup)
    
}