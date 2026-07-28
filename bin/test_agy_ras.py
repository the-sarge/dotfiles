#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import textwrap
import unittest


WRAPPER = Path(__file__).with_name("agy-ras")
CAPTURE_INVOCATION = """\
    #!/usr/bin/env python3
    import json
    import sys

    print(json.dumps({"args": sys.argv[1:], "stdin": sys.stdin.read()}))
    """


class AgyRasTests(unittest.TestCase):
    def run_wrapper(
        self,
        args: list[str],
        prompt: str,
        fake_agy_source: str = CAPTURE_INVOCATION,
    ) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_agy = temp_path / "fake-agy"
            fake_agy.write_text(textwrap.dedent(fake_agy_source))
            fake_agy.chmod(0o755)
            env = os.environ.copy()
            env["AGY_REAL"] = str(fake_agy)
            env["HOME"] = str(temp_path)

            return subprocess.run(
                [sys.executable, str(WRAPPER), *args],
                input=prompt,
                text=True,
                capture_output=True,
                env=env,
                check=False,
            )

    def test_ras_stdin_becomes_print_prompt(self) -> None:
        prompt = 'line one\nline two with "quotes" and $dollar\n'
        result = self.run_wrapper(
            [
                "--ras-stdin",
                "--model",
                "gemini-test",
                "--print-timeout",
                "15m",
            ],
            prompt,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        invocation = json.loads(result.stdout)
        self.assertEqual(
            invocation["args"],
            [
                "--model",
                "gemini-test",
                "--print-timeout",
                "15m",
                "--print",
                prompt,
            ],
        )
        self.assertEqual(invocation["stdin"], "")

    def test_ras_stdin_rejects_an_explicit_prompt(self) -> None:
        explicit_prompt_forms = [
            ["--print", "explicit prompt"],
            ["--prompt", "explicit prompt"],
            ["-p", "explicit prompt"],
            ["--print=explicit prompt"],
            ["--prompt=explicit prompt"],
            ["-p=explicit prompt"],
        ]

        for explicit_prompt in explicit_prompt_forms:
            with self.subTest(explicit_prompt=explicit_prompt):
                result = self.run_wrapper(
                    ["--ras-stdin", *explicit_prompt],
                    "stdin prompt",
                )

                self.assertEqual(result.returncode, 2)
                self.assertIn(
                    "--ras-stdin conflicts with an explicit prompt",
                    result.stderr,
                )

    def test_ras_stdin_rejects_an_empty_prompt(self) -> None:
        result = self.run_wrapper(["--ras-stdin"], "")

        self.assertEqual(result.returncode, 2)
        self.assertIn("--ras-stdin received an empty stdin prompt", result.stderr)

    def test_invocation_without_ras_stdin_remains_transparent(self) -> None:
        prompt = "manual stdin\n"
        result = self.run_wrapper(["--model", "gemini-test"], prompt)

        self.assertEqual(result.returncode, 0, result.stderr)
        invocation = json.loads(result.stdout)
        self.assertEqual(invocation["args"], ["--model", "gemini-test"])
        self.assertEqual(invocation["stdin"], prompt)

    def test_ras_stdin_supports_full_context_prompt_size(self) -> None:
        prompt = "x" * 400_000
        result = self.run_wrapper(
            ["--ras-stdin"],
            prompt,
            """\
            #!/usr/bin/env python3
            import sys

            print(len(sys.argv[sys.argv.index("--print") + 1]))
            """,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(len(prompt)))


if __name__ == "__main__":
    unittest.main()
