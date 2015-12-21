# liquidFlux

early alpha stage

#### Motivation

> There are a lot of flux implementations out there in the wide world of open source, i tried a few, but i wasn't satisfied with one of them. \
> few of them are overloaded, others doing things in too complicated ways, but most just dont fit in my way of thinking and writing or dont fulfill the requirements of my current projects \
\
> so i decided to write my own framework, not only Flux for the frontend, also for the backend and everything needed in between and React-mixin on top\
> simple, live, fast and open source! ;)






# Features
3 Collections, sharing more of the code

![chart](https://raw.githubusercontent.com/alangecker/liquidflux/master/chart.png)

#### Flux Frontend
  - mixin for React
    - listens on Store changes
  - Actions
  - Dispatcher
     - distributes actions to all listening stores
  - Stores
  - Queries
    - caching results
    - triggers Actions
  - API
    - over socket.io
    - handles responses & listens for update

#### Proxy
- caches all as 'cacheable' marked responses
- possible to replicate for speed and reliability
- delivers cached content without connection to the backend
    - *an important requirement for our festival volunteers schedule project, having an relay locally if the mobile connection gets lost*
 - communicates to the backend over redis (tcp)


#### Flux backend (kind of)
  - Routes Requests from redis
  - Middleware
    - input validation
    - access restriction
    - ...
  - Requests trigger Actions
  - Dispatcher
      - can handle Promises from the stores to the Actions
  - Stores
  - contentGenerators for Response


# Example
will come soon... ;)
