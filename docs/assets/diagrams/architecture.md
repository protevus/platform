# Platform Architecture Diagrams

## Package Architecture
```mermaid
graph TD
    subgraph Core ["Core Framework"]
        Container[illuminate/container]
        Support[illuminate/support]
        Foundation[illuminate/foundation]
        Http[illuminate/http]
        Routing[illuminate/routing]
        Database[illuminate/database]
    end

    subgraph Contracts ["Contracts Layer"]
        ContainerContract[container_contract]
        EventContract[event_contract]
        HttpContract[http_contract]
        RouteContract[route_contract]
        QueueContract[queue_contract]
        PipelineContract[pipeline_contract]
    end

    subgraph Infrastructure ["Infrastructure"]
        Events[events]
        Queue[queue]
        Pipeline[pipeline]
        Bus[bus]
        Process[process]
        Model[model]
    end

    %% Contract Dependencies
    Container --> ContainerContract
    Events --> EventContract
    Http --> HttpContract
    Routing --> RouteContract
    Queue --> QueueContract
    Pipeline --> PipelineContract

    %% Core Dependencies
    Foundation --> Container
    Http --> Container
    Routing --> Http
    Database --> Container

    %% Infrastructure Dependencies
    Events --> Container
    Queue --> Container
    Pipeline --> Container
    Bus --> Events
    Process --> Container
    Model --> Database
```

## Request Lifecycle
```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Http
    participant Router
    participant Pipeline
    participant Controller
    participant Container

    Client->>Server: HTTP Request
    Server->>Http: Handle Request
    Http->>Router: Route Request
    Router->>Pipeline: Process Middleware
    Pipeline->>Container: Resolve Dependencies
    Container->>Controller: Inject Dependencies
    Controller->>Client: Return Response
```

## Service Container Flow
```mermaid
graph LR
    subgraph Container ["Container"]
        Bind[Bind Service]
        Resolve[Resolve Service]
        Make[Make Instance]
    end

    subgraph Provider ["Service Provider"]
        Register[Register Services]
        Boot[Boot Services]
    end

    subgraph Application ["Application"]
        Request[Handle Request]
        Response[Return Response]
    end

    Register --> Bind
    Request --> Resolve
    Resolve --> Make
    Make --> Response
    Boot --> Request
```

## Event System
```mermaid
graph TD
    subgraph Events ["Event System"]
        Dispatcher[Event Dispatcher]
        Listener[Event Listener]
        Queue[Queue Listener]
    end

    subgraph Application ["Application"]
        Event[Fire Event]
        Handler[Handle Event]
    end

    Event --> Dispatcher
    Dispatcher --> Listener
    Dispatcher --> Queue
    Listener --> Handler
    Queue --> Handler
```

## Database Layer
```mermaid
graph TD
    subgraph Models ["Model Layer"]
        Model[Eloquent Model]
        Relation[Model Relations]
        Observer[Model Observer]
    end

    subgraph Database ["Database"]
        Query[Query Builder]
        Schema[Schema Builder]
        Migration[Migrations]
    end

    subgraph Events ["Events"]
        Created[Created Event]
        Updated[Updated Event]
        Deleted[Deleted Event]
    end

    Model --> Query
    Model --> Relation
    Model --> Observer
    Observer --> Created
    Observer --> Updated
    Observer --> Deleted
    Query --> Schema
    Schema --> Migration
```

## Package Dependencies
```mermaid
graph TD
    subgraph Core ["Core Packages"]
        Container[container]
        Support[support]
        Foundation[foundation]
    end

    subgraph Features ["Feature Packages"]
        Http[http]
        Routing[routing]
        Database[database]
        Cache[cache]
    end

    subgraph Infrastructure ["Infrastructure"]
        Events[events]
        Queue[queue]
        Pipeline[pipeline]
    end

    %% Core Dependencies
    Support --> Container
    Foundation --> Container
    Foundation --> Support

    %% Feature Dependencies
    Http --> Foundation
    Routing --> Http
    Database --> Foundation
    Cache --> Foundation

    %% Infrastructure Dependencies
    Events --> Container
    Queue --> Events
    Pipeline --> Container
