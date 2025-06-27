# final_review_gate.py
import sys
import os
import datetime


if __name__ == "__main__":
    # Attempt to set unbuffered output, useful in some environments
    try:
        sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', buffering=1)
        sys.stderr = os.fdopen(sys.stderr.fileno(), 'w', buffering=1)
    except Exception:
        # Fallback if unbuffered output cannot be set (e.g., in certain IDE terminals)
        pass


    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] Review Gate: The current step's initial implementation is complete.", flush=True)
    print(f"[{timestamp}] Please provide your sub-prompt for iterative modifications for THIS STEP,", flush=True)
    print(f"[{timestamp}] or enter an exit keyword (e.g., '完成', 'next', 'task_complete', 'continue', 'ok') to finalize THIS STEP's review:", flush=True)


    active_session = True
    prompt_count = 0
    while active_session:
        prompt_count += 1
        try:
            # Read input from stdin
            line = sys.stdin.readline()


            if not line:  # EOF detected (e.g., if the input stream is closed)
                eof_timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                print(f"[{eof_timestamp}] --- REVIEW GATE: STDIN closed (EOF detected). Exiting review script for this step. ---", flush=True)
                active_session = False
                break


            user_input = line.strip()
            input_timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


            if not user_input: # Empty line, prompt again
                print(f"[{input_timestamp}] Review Gate (Prompt #{prompt_count}): Waiting for input...", flush=True)
                continue


            user_input_lower = user_input.lower() # For case-insensitive matching of English keywords


            # Keywords to end the review for the current step
            english_exit_keywords = [
                'task_complete', 'continue', 'next', 'end', 'complete', 'endtask',
                'continue_task', 'end_task', 'ok', 'okay', 'done', 'proceed', 'accept', 'approved',
                'submit', 'final', 'finish', 'go'
            ]
            chinese_exit_keywords = [
                '没问题', '继续', '下一步', '完成', '结束任务', '结束', '可以', '好了', '通过', '接受',
                '提交', '最终', '搞定', '行'
            ]


            is_exit_keyword_detected = False
            if user_input_lower in english_exit_keywords:
                is_exit_keyword_detected = True
            else:
                for ch_keyword in chinese_exit_keywords: # Chinese keywords match exactly
                    if user_input == ch_keyword:
                        is_exit_keyword_detected = True
                        break
           
            if is_exit_keyword_detected:
                print(f"[{input_timestamp}] --- REVIEW GATE: User ended review for THIS STEP with keyword: '{user_input}' (after {prompt_count} prompts) ---", flush=True)
                active_session = False
                break
            else:
                # If it's not an exit keyword, treat it as a sub-prompt for the AI
                print(f"USER_REVIEW_SUB_PROMPT: {user_input}", flush=True) # AI needs to listen for this exact format


        except KeyboardInterrupt:
            kb_timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{kb_timestamp}] --- REVIEW GATE: User interrupted (Ctrl+C). Exiting review script for this step. ---", flush=True)
            active_session = False
            break
        except Exception as e:
            err_timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{err_timestamp}] --- REVIEW GATE: An error occurred in the review script for this step: {e} ---", flush=True)
            active_session = False
            break 