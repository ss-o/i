package handler_test

import (
	"net/http/httptest"
	"os"
	"os/exec"
	"testing"

	"github.com/ss-o/i/handler"
)

func TestCloudflared(t *testing.T) {
	h := &handler.Handler{}
	r := httptest.NewRequest("GET", "/cloudflare/cloudflared", nil)
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	t.Log(w.Body.String())
	if w.Result().StatusCode != 200 {
		t.Fatalf("failed to get cloudflare/cloudflared asset status")
	}
}

func TestMicro(t *testing.T) {
	h := &handler.Handler{}
	r := httptest.NewRequest("GET", "/micro", nil)
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	t.Log(w.Body.String())
	if w.Result().StatusCode != 200 {
		t.Fatalf("failed to get micro asset status")
	}
}

func TestMicroDoubleBang(t *testing.T) {
	h := &handler.Handler{}
	r := httptest.NewRequest("GET", "/micro!!", nil)
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	t.Log(w.Body.String())
	if w.Result().StatusCode != 200 {
		t.Fatalf("failed to get micro!! asset status")
	}
}

func TestGotty(t *testing.T) {
	h := &handler.Handler{}
	r := httptest.NewRequest("GET", "/yudai/gotty@v0.0.12", nil)
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	t.Log(w.Body.String())
	if w.Result().StatusCode != 200 {
		t.Fatalf("failed to get yudai/gotty status")
	}
}

func TestMicroInstall(t *testing.T) {
	h := &handler.Handler{}
	r := httptest.NewRequest("GET", "/micro?type=script", nil)
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	if w.Result().StatusCode != 200 {
		t.Fatalf("failed to get micro asset status")
	}
	// pipe into bash
	bash := exec.Command("bash")
	bash.Stdin = w.Body
	bash.Dir = os.TempDir()
	out, err := bash.CombinedOutput()
	if err != nil {
		t.Fatalf("failed to install micro: %s %s", err, out)
	}
	t.Log(string(out))
}

func TestMicroInstallAs(t *testing.T) {
	h := &handler.Handler{}
	r := httptest.NewRequest("GET", "/micro?type=script&as=mymicro", nil)
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	if w.Result().StatusCode != 200 {
		t.Fatalf("failed to get micro asset status")
	}
	// pipe into bash
	bash := exec.Command("bash")
	bash.Stdin = w.Body
	bash.Dir = os.TempDir()
	out, err := bash.CombinedOutput()
	if err != nil {
		t.Fatalf("failed to install micro as mymicro: %s %s", err, out)
	}
	t.Log(string(out))
}
