ARG ALPINE_VERSION=20230901
FROM alpine:$ALPINE_VERSION AS ifc-build

RUN apk add --no-cache cmake make msgsl g++ musl-dbg

# version 0.43 does NOT contain proper files to build with cmake
ARG IFC_VERSION=main
RUN (wget https://github.com/microsoft/ifc/archive/refs/heads/$IFC_VERSION.zip || wget https://github.com/microsoft/ifc/archive/refs/tags/$IFC_VERSION.zip) \
    && unzip $IFC_VERSION.zip \
    && rm $IFC_VERSION.zip
WORKDIR /ifc-$IFC_VERSION/

COPY CMakeUserPresets.json .

RUN cmake --preset=dev  # configure
# change DESTINATION to bin/ so we don't need to modify PATH var
RUN sed -i 's/TARGETS ifc-printer DESTINATION . COMPONENT Printer/TARGETS ifc-printer DESTINATION bin COMPONENT Printer/' /ifc-$IFC_VERSION/cmake/install-rules.cmake
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
