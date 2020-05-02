interface AWSAppSyncEvent<Fields> {
    field: Fields;
    args?: AWSAppSyncEventArguments;
    source?: AWSAppSyncEventSource
}

type AWSAppSyncEventArguments = { [key: string]: any }

type AWSAppSyncEventSource = { [key: string]: any }

type ResolverFields<TResolver> = keyof TResolver;


interface Resolver {
    readonly field: string
}

type Handler<TEvent = any, TResult = any> = (
    event: TEvent,
    context: Context,
    callback: Callback<TResult>,
) => void | Promise<TResult>;


type Callback<TResult = any> = (error?: Error | string | null, result?: TResult) => void;
