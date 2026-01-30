extends Node
class_name Coroutines

func await_all(list: Array):
	var counter = { value = list.size() }
	for el in list:
		if el is Signal:
			el.connect(count_down.bind(counter), CONNECT_ONE_SHOT)
		elif el is Callable:
			# Handle awaitable functions (coroutines) by wrapping them
			func_wrapper(el, count_down.bind(counter))
	
	# Wait until all operations are complete
	while counter.value > 0:
		await get_tree().process_frame

func count_down(dict):
	dict.value -= 1

func func_wrapper(callable_object: Callable, call_back: Callable):
	await callable_object.call() # Await the function execution
	call_back.call()
