/// Get an instance of type from the pool, or create a new one with the given arguments.
/// Usage: POOL_TAKE(/obj/foo, loc, arg2)
#define POOL_TAKE(type, ...) SSobject_pool.Take(type, ##__VA_ARGS__)

/// Return an instance to the pool (resets its vars from template and clears refs).
#define POOL_RELEASE(obj) SSobject_pool.Release(obj).
#define POOL_ASYNC_RELEASE(obj) SSobject_pool.ReleaseAsync(obj)

/// Destroy an instance without returning it to the pool (qdel).
#define POOL_DELETE(obj) SSobject_pool.Delete(obj)

/// Ensure a type is registered in the pool (creates template if needed). Optional before first POOL_TAKE.
#define POOL_REGISTER(type) SSobject_pool.RegisterType(type)
