ARG ALPINE_VERSION=3.18.4
FROM alpine:$ALPINE_VERSION AS ifc-build

RUN apk add --no-cache cmake make msgsl g++ musl-dbg

# version 0.43 does NOT contain proper files to build with cmake
ARG IFC_VERSION=main
ARG ARCHIVE_URL=https://github.com/whoan/ifc/archive/
RUN (wget $ARCHIVE_URL/refs/heads/$IFC_VERSION.zip || wget $ARCHIVE_URL/refs/tags/$IFC_VERSION.zip || wget $ARCHIVE_URL/$IFC_VERSION.zip) \
    && unzip $IFC_VERSION.zip \
    && rm $IFC_VERSION.zip
WORKDIR /ifc-$IFC_VERSION/

COPY CMakeUserPresets.json .

RUN cmake --preset=dev  # configure
RUN cmake --build --preset=dev  # build
RUN ctest --preset=dev  # does it return != 0 if tests dont pass?
RUN cmake --install build/dev --prefix /usr/local/


FROM alpine:$ALPINE_VERSION

RUN apk add --no-cache libstdc++

COPY --from=ifc-build /usr/local/bin/ifc-printer /usr/local/bin/ifc-printer
COPY --from=ifc-build /usr/local/include/ifc /usr/local/include/ifc
COPY --from=ifc-build /usr/local/lib/libifc-dom.a /usr/local/lib/libifc-dom.a
COPY --from=ifc-build /usr/local/lib/libifc-reader.a /usr/local/lib/libifc-reader.a
COPY --from=ifc-build /usr/local/lib/cmake/Microsoft.IFC /usr/local/lib/cmake/Microsoft.IFC
