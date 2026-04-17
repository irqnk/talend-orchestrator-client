"""
Agent Windows — exécute les jobs .bat/.ps1 sur la machine hôte Windows
et streame la sortie vers le conteneur Docker.

Lancer avec : agent_windows.bat
Port par défaut : 8002
"""
import os
import subprocess
import re
import logging
from flask import Flask, request, Response, stream_with_context, jsonify

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)

AGENT_SECRET  = os.environ.get('AGENT_SECRET', 'talend-agent-secret')
BASE_DIR      = os.path.dirname(os.path.abspath(__file__))
AGENT_PORT    = int(os.environ.get('AGENT_PORT', 8002))

_CMD_ECHO_RE = re.compile(r'^[A-Za-z]:\\[^>]*>')


def _docker_path_to_windows(docker_path: str) -> str:
    """
    Convertit un chemin Docker (/app/job/...) en chemin Windows local.
    Ex: /app/job/ZIP_Talend/... → C:\\XD\\git\\talend_orchestrator\\job\\ZIP_Talend\\...
    """
    # Supprimer le préfixe /app
    rel = docker_path
    if rel.startswith('/app/'):
        rel = rel[5:]
    elif rel.startswith('/app'):
        rel = rel[4:]
    # Remplacer les slashes Linux par Windows
    rel = rel.replace('/', os.sep)
    return os.path.join(BASE_DIR, rel)


@app.route('/ping', methods=['GET'])
def ping():
    """Vérifier que l'agent est bien démarré."""
    return jsonify({'status': 'ok', 'base_dir': BASE_DIR})


@app.route('/execute', methods=['POST'])
def execute():
    """
    Exécute un script .bat/.ps1 et streame la sortie ligne par ligne.

    Body JSON :
      {
        "secret":      "talend-agent-secret",
        "script_path": "/app/job/ZIP_Talend/.../coucou_run.bat",
        "context":     "DEV"   (optionnel)
      }
    """
    data = request.get_json(silent=True) or {}

    # Vérification du secret
    if data.get('secret') != AGENT_SECRET:
        logger.warning('Tentative non autorisée depuis %s', request.remote_addr)
        return jsonify({'error': 'Non autorisé'}), 401

    docker_path = data.get('script_path', '')
    context     = data.get('context', '')

    # Traduire le chemin Docker → Windows
    win_path = _docker_path_to_windows(docker_path)
    logger.info('Exécution demandée : %s → %s (context=%s)', docker_path, win_path, context)

    if not os.path.isfile(win_path):
        return jsonify({'error': f'Fichier introuvable : {win_path}'}), 404

    # Construire la commande
    win_path_q = f'"{win_path}"' if ' ' in win_path else win_path
    ctx_suffix = f' --context={context}' if context else ''

    if win_path.lower().endswith('.ps1'):
        cmd = ['powershell', '-ExecutionPolicy', 'Bypass', '-File', win_path]
        if context:
            cmd.append(f'--context={context}')
    else:
        cmd = ['cmd', '/c', f'{win_path_q}{ctx_suffix}']

    def generate():
        try:
            proc = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                cwd=os.path.dirname(win_path),
                text=True,
                bufsize=1,
            )
            for line in proc.stdout:
                if _CMD_ECHO_RE.match(line):
                    continue  # ignorer les échos cmd.exe
                yield line
            proc.wait()
            # Ligne spéciale pour signaler le code de sortie
            yield f'\n__EXIT_CODE__{proc.returncode}__\n'
        except Exception as e:
            yield f'\n[ERREUR AGENT] {e}\n__EXIT_CODE__1__\n'

    return Response(stream_with_context(generate()), mimetype='text/plain; charset=utf-8')


if __name__ == '__main__':
    from waitress import serve
    logger.info('=== Talend Windows Agent démarré sur http://0.0.0.0:%d ===', AGENT_PORT)
    logger.info('Base dir : %s', BASE_DIR)
    serve(app, host='0.0.0.0', port=AGENT_PORT, threads=4)
