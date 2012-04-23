#include <gvc.h>
#include <string.h>

extern gvplugin_library_t gvplugin_dot_layout_LTX_library;
extern gvplugin_library_t gvplugin_core_LTX_library;

// To work around a bug in emscripten
#include <dirent.h>
struct dirent _fake_dirent;

static GVC_t *gvc;
enum {ERRBUF_LEN = 1024};
static char errbuf[ERRBUF_LEN];

static int emusererrf(char *str)
{
    strncpy(errbuf, str, ERRBUF_LEN-1);
    errbuf[ERRBUF_LEN-1] = 0;
    return 0;
}

char *emGvRecentError()
{
    return errbuf;
}

char *graphvizjs(char *input, char *layoutType, char *format)
{
    graph_t *g;
    char *output = NULL;
    unsigned int outputLength = 0;
    int res = 0;

    if (!gvc) {
        gvc = gvContext();

        // Define the static plugins
        gvAddLibrary(gvc, &gvplugin_core_LTX_library);
        gvAddLibrary(gvc, &gvplugin_dot_layout_LTX_library);

        agseterrf(emusererrf);
    }

    g = agmemread(input);
    gvLayout(gvc, g, layoutType);
    res = gvRenderData(gvc, g, format, &output, &outputLength);
    gvFreeLayout(gvc, g);
    agclose(g);

    if (res == 0) return output;
    else return NULL;
}
