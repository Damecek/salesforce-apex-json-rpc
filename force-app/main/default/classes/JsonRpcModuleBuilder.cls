/**
 * Base builder for explicit module registration.
 */
public abstract inherited sharing class JsonRpcModuleBuilder {
    /**
     * Registers handlers into the provided module.
     *
     * @param module Target module to configure.
     */
    public abstract void configure(JsonRpcModule module);

    /**
     * Builds a module by invoking configure().
     *
     * @return Configured module.
     */
    public JsonRpcModule build() {
        JsonRpcModule module = new JsonRpcModule();
        this.configure(module);
        return module;
    }
}
