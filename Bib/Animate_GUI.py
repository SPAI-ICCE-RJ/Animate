"""
Título do Script: Script de Animação (Animate_GUI.py)
Versão: 2.0
Data da Versão: 14/12/2024

Descrição:
Este script tem o propósito de gerar animações a partir de uma série de quadros e anexá-las a um PDF 
especificado, operando através de uma interface gráfica. É possível configurar a taxa de quadros, 
o número do laudo e, opcionalmente, anexar o resultado a um PDF principal. Além disso, existe a opção 
de criptografar o apêndice (a animação resultante) antes de incorporá-lo internamente no documento, 
permitindo proteger o conteúdo sensível com uma senha.

Principais Funcionalidades da Versão 1.3:
- Agora, o apêndice criptografado não é mesclado diretamente via pdftk, evitando erros de senha. 
  Ao invés disso, o PDF criptografado é embutido internamente ao Anime.pdf via \attachfile no LaTeX, 
  resultando em um PDF final não protegido para mesclagem com o documento principal, mas contendo 
  internamente o PDF criptografado.
- Dupla compilação do LaTeX quando o PDF com anexo criptografado é gerado, para evitar páginas temporárias.
- Limpeza de todos os campos, incluindo a senha, ao iniciar uma nova execução.
- Redirecionamento de todas as saídas para o arquivo de log Anime_out.txt, mantendo o console limpo.
- Documentação atualizada.

Requerimentos:
- Python 3.7 ou superior
- tkinter (parte da biblioteca padrão do Python)
- subprocess (parte da biblioteca padrão do Python)
- pdflatex (MikTeX portable ou instalado no PATH)
- pdftk (incluído no diretório Bib)

Funções:
- generate_anime_tex: Gera o arquivo Anime.tex com as animações.
- generate_anime_with_attachment_tex: Gera o Anime.tex para embutir o PDF criptografado via \attachfile.
- compile_latex: Compila o Anime.tex usando pdflatex, armazenando logs em Auxs\.
- encrypt_pdf: Criptografa o PDF Anime.pdf, gerando um PDF protegido.
- attach_pdf: Anexa o PDF final ao PDF principal (sem necessidade de senha neste estágio).
- validate_inputs: Valida todos os parâmetros de entrada.
- show_about: Exibe informações sobre a aplicação, incluindo a versão 1.3.
- show_help: Abre o arquivo Readme.txt.
- ask_new_execution: Pergunta ao usuário se deseja iniciar uma nova execução, limpando os campos.
- main: Função principal que inicializa a interface gráfica, gerencia os eventos e chama execute().

Autores:
Originalmente desenvolvido em (Power)shell por Gustavo Maia Q de Mendonça
Portado para Python por Danilo Caio Marcucci Marques
Adaptado posteriormente para a versão 2.0 com novas funcionalidades.
"""

import os
import sys
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import re
import time
import glob
import shutil
import ctypes

def get_resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

ROOT_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
AUX_DIR = get_resource_path("Auxs")
MKTEX_PATH = get_resource_path(os.path.join("miktex", "texmfs", "install", "miktex", "bin", "x64", "pdflatex.exe"))
PDFTK_PATH = get_resource_path(os.path.join("Bib", "pdftk.exe"))
README_PATH = get_resource_path("Readme.md")
LOG_FILE_PATH = os.path.join(ROOT_DIR,"Auxs", "interface_out.log")

# Redirecionar stdout e stderr para o arquivo de log, mantendo o console limpo
sys.stdout = open(LOG_FILE_PATH, 'w', encoding='utf-8')
sys.stderr = sys.stdout

def check_file_usage(file_path):
    for _ in range(10):
        try:
            if os.path.exists(file_path):
                os.rename(file_path, file_path)
            return False
        except OSError:
            time.sleep(0.5)
    return True

def safe_remove(file_path):
    if os.path.exists(file_path):
        if not check_file_usage(file_path):
            try:
                os.remove(file_path)
            except Exception as e:
                print(f"Erro ao remover {file_path}: {e}")
        else:
            print(f"Aviso: Não foi possível remover {file_path} pois está em uso.")

def check_pdflatex():
    global MKTEX_PATH
    if not os.path.exists(MKTEX_PATH):
        MKTEX_PATH = 'pdflatex.exe'
     ##   if not any(
     ##       os.access(os.path.join(path, "pdflatex.exe"), os.X_OK)
     ##       for path in os.environ["PATH"].split(os.pathsep)
     ##   ):
     ##       messagebox.showerror("Erro", "pdflatex.exe não encontrado. Verifique o MikTeX portable ou o PATH.")
     ##       sys.exit(1)
   ## print("pdflatex encontrado e válido.")

def generate_anime_tex(folder_path, frame_rate, laudo_number, anime_tex_path):
    try:
        with open(anime_tex_path, 'w', encoding='utf-8') as f:
            f.write(r'\documentclass[12pt, a4paper]{article}' + '\n')
            f.write(r'\usepackage{Bib/laudo}' + '\n')
            if laudo_number:
                f.write(rf'\laudo{{Laudo: {laudo_number}}}' + '\n')
            f.write(rf'\pathframe{{{folder_path.replace("\\", "/")}}}' + '\n')
            f.write(rf'\framerate{{{frame_rate}}}' + '\n')
            f.write(r'\begin{document}' + '\n')
            f.write(r'\front' + '\n')
            f.write(r'\animations' + '\n')
            f.write(r'\videos' + '\n')
            f.write(r'\audios' + '\n')
            f.write(r'\attachments' + '\n')
            f.write(r'\datas' + '\n')
            f.write(r'\end{document}' + '\n')
    except Exception as e:
        print(f"Error generating Anime.tex: {e}")

def generate_anime_with_attachment_tex(laudo_number, attachment_path, anime_tex_path):
    try:
        with open(anime_tex_path, 'w', encoding='utf-8') as f:
            f.write(r'\documentclass[12pt, a4paper]{article}' + '\n')
            f.write(r'\usepackage{Bib/laudo}' + '\n')
            f.write(rf'\laudo{{Laudo: {laudo_number}}}' + '\n')
            f.write(r'\begin{document}' + '\n')
            f.write(r'\front' + '\n')
            attachment_path_latex = attachment_path.replace("\\", "/")
            f.write(rf'\begin{{figure}}\centering \textattachfile[color=0 0 0]{{{attachment_path_latex}}}{{\centering\cadeado{{}}}}\captionsetup{{labelformat=empty}}\caption{{O conteúdo das Multimídias foi protegido no arquivo acima por senha indicada na Seção Material deste Laudo.}}\end{{figure}}' + '\n')
            f.write(r'\end{document}' + '\n')
    except Exception as e:
        print(f"Error generating Anime with attachment tex: {e}")

def compile_latex(anime_tex_path):
    print(f"Compilando LaTeX: {anime_tex_path}")
    try:
        subprocess.run([MKTEX_PATH, '-interaction=nonstopmode', '-aux-directory', AUX_DIR, '--shell-escape', anime_tex_path], check=True, capture_output=True, text=True)
        result = subprocess.run([MKTEX_PATH, '-interaction=nonstopmode', '-aux-directory', AUX_DIR, '--shell-escape', anime_tex_path], check=True, capture_output=True, text=True)
        print("Saída do pdflatex (stdout):")
        print(result.stdout)
        print("Saída do pdflatex (stderr):")
        print(result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error compiling LaTeX file: {e}")
        print("stdout:", e.stdout)
        print("stderr:", e.stderr)
        return False
    return True

def encrypt_pdf(input_pdf_path, output_pdf_path, user_pw):
    if not os.path.exists(input_pdf_path):
        raise FileNotFoundError(f"Arquivo para criptografar não encontrado: {input_pdf_path}")
    owner_pw = "PeritO!@" + user_pw
    print(f"Criptografando PDF: {input_pdf_path} => {output_pdf_path}")
    # print(f"user_pw: {user_pw}, owner_pw: {owner_pw}")
    try:
        cmd = [
            PDFTK_PATH, input_pdf_path, 'output', output_pdf_path,
            'owner_pw', owner_pw,
            'user_pw', user_pw
        ]
        # print("Comando criptografia:", cmd)
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("Criptografia stdout:", result.stdout)
        print("Criptografia stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error encrypting PDF: {e}")
        print("stdout:", e.stdout)
        print("stderr:", e.stderr)
        raise

def attach_pdf(base_pdf_path, anime_pdf_path):
    output_pdf_path = base_pdf_path.replace('.pdf', '_A.pdf')
    if not os.path.exists(anime_pdf_path):
        raise FileNotFoundError(f"Arquivo para anexar não encontrado: {anime_pdf_path}")

    command = [PDFTK_PATH, base_pdf_path, anime_pdf_path, 'cat', 'output', output_pdf_path]
    print("Comando anexar (sem senha):", command)
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        print("Anexar stdout:", result.stdout)
        print("Anexar stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print("Erro ao anexar:")
        print("stdout:", e.stdout)
        print("stderr:", e.stderr)
        raise
    return output_pdf_path

def validate_inputs(folder_path, frame_rate, laudo_number, pdf_path, attach_pdf_checked, encrypt_pdf_checked, password):
    # Se existir a pasta Sequences, exigir taxa de quadros preenchida e válida
    sequences_dir = os.path.join(folder_path, "Sequences")
    if os.path.isdir(sequences_dir):
        try:
            if not frame_rate or float(frame_rate) <= 0:
                messagebox.showinfo("Atenção", "Taxa de quadros não definida ou inválida (obrigatória para Sequences).")
                return False
        except ValueError:
            messagebox.showinfo("Atenção", "Taxa de quadros inválida (obrigatória para Sequences).")
            return False

    if not os.path.exists(folder_path):
        messagebox.showerror("Erro", "O caminho da pasta raiz é inválido")
        return False

    # if attach_pdf_checked or encrypt_pdf_checked:
    #    laudo_pattern = re.compile(r'^\d{1,6}/(19|20)\d{2}(-\d{1})?$')
    #    if not laudo_number or not laudo_pattern.match(laudo_number):
    #        messagebox.showerror("Erro", "Número do laudo é inválido ou está em branco")
    #        return False

    if attach_pdf_checked:
        if not os.path.exists(pdf_path):
            messagebox.showerror("Erro", "O caminho do PDF para anexar é inválido")
            return False

    if encrypt_pdf_checked:
        if not password:
            messagebox.showerror("Erro", "A senha para criptografia não pode estar em branco")
            return False

    return True

def show_about():
    messagebox.showinfo(
        "Sobre",
        "Versão 1.2\n"
        "Este script gera animações em PDF a partir de quadros, podendo anexá-las a um PDF principal.\n"
        "Novidade da versão 1.2: Apêndice criptografado incorporado internamente, evitando erros de concatenação.\n"
        "Originalmente desenvolvido em (Power)shell por Gustavo Maia Q de Mendonça\n"
        "Portado para Python por Danilo Caio Marcucci Marques"
    )

def show_help():
    if os.path.exists(README_PATH):
        os.startfile(README_PATH)
    else:
        messagebox.showerror("Erro", "Arquivo Readme.txt não encontrado")

def copy_media_files_to_root(folder_path, root_dir):
    # Copia todos os .mp4 da pasta Videos
    videos_dir = os.path.join(folder_path, "Videos")
    if os.path.exists(videos_dir):
        for file in glob.glob(os.path.join(videos_dir, "Video*.mp4")):
            dest = os.path.join(root_dir, os.path.basename(file))
            shutil.copy2(file, dest)
            # Oculta o arquivo copiado
            try:
                ctypes.windll.kernel32.SetFileAttributesW(dest, 2)  # 2 = FILE_ATTRIBUTE_HIDDEN
            except Exception as e:
                print(f"Erro ao ocultar {dest}: {e}")
    # Copia todos os .mp3 da pasta Audios
    audios_dir = os.path.join(folder_path, "Audios")
    if os.path.exists(audios_dir):
        for file in glob.glob(os.path.join(audios_dir, "Audio*.mp3")):
            dest = os.path.join(root_dir, os.path.basename(file))
            shutil.copy2(file, dest)
            try:
                ctypes.windll.kernel32.SetFileAttributesW(dest, 2)
            except Exception as e:
                print(f"Erro ao ocultar {dest}: {e}")
    # Copia todos os .pdf da pasta Files
    files_dir = os.path.join(folder_path, "Files")
    if os.path.exists(files_dir):
        for file in glob.glob(os.path.join(files_dir, "File*.pdf")):
            dest = os.path.join(root_dir, os.path.basename(file))
            shutil.copy2(file, dest)
            try:
                ctypes.windll.kernel32.SetFileAttributesW(dest, 2)
            except Exception as e:
                print(f"Erro ao ocultar {dest}: {e}")

def remove_media_files_from_root(root_dir):
    # Remove todos os .mp4, .mp3 e .pdf da raiz do projeto
    for file in glob.glob(os.path.join(root_dir, "Video*.mp4")) + \
                glob.glob(os.path.join(root_dir, "Audio*.mp3")) + \
                glob.glob(os.path.join(root_dir, "File*.pdf")):
        try:
            os.remove(file)
        except Exception as e:
            print(f"Erro ao remover {file}: {e}")

def main():
    root = tk.Tk()
    root.title("Animation Script")

    # Define o ícone da janela
    root.iconbitmap(get_resource_path("Bib/icon.ico"))

    window_width = 450
    window_height = 500
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    position_top = int(screen_height / 2 - window_height / 2)
    position_right = int(screen_width / 2 - window_width / 2)
    root.geometry(f'{window_width}x{window_height}+{position_right}+{position_top}')

    anime_tex_path = os.path.join(ROOT_DIR, "Anime.tex")
    anime_pdf_path = os.path.join(ROOT_DIR, "Anime.pdf")

    safe_remove(anime_tex_path)
    safe_remove(anime_pdf_path)

    def select_root_folder():
        folder_selected = filedialog.askdirectory()
        entry_folder_path.delete(0, tk.END)
        entry_folder_path.insert(0, folder_selected)

    def select_pdf_file():
        file_selected = filedialog.askopenfilename(filetypes=[("PDF files", "*.pdf")])
        entry_pdf_path.delete(0, tk.END)
        entry_pdf_path.insert(0, file_selected)

    def toggle_pdf_selection():
        if attach_pdf_var.get() or encrypt_pdf_var.get():
            pdf_button.config(state=tk.NORMAL)
            entry_pdf_path.config(state=tk.NORMAL)
        else:
            pdf_button.config(state=tk.DISABLED)
            entry_pdf_path.config(state=tk.DISABLED)

        if encrypt_pdf_var.get():
            attach_pdf_var.set(True)
            password_entry.config(state=tk.NORMAL)
        else:
            password_entry.config(state=tk.DISABLED)

    frame_rate_label = tk.Label(root, text="Taxa de quadros:")
    frame_rate_label.grid(row=0, column=0, padx=10, pady=5)
    entry_framerate = tk.Entry(root)
    entry_framerate.grid(row=0, column=1, padx=10, pady=5)

    folder_path_label = tk.Label(root, text="Pasta raiz:")
    folder_path_label.grid(row=1, column=0, padx=10, pady=5)
    entry_folder_path = tk.Entry(root)
    entry_folder_path.grid(row=1, column=1, padx=10, pady=5)
    folder_button = tk.Button(root, text="Selecionar", command=select_root_folder)
    folder_button.grid(row=1, column=2, padx=10, pady=5)

    entry_folder_path.grid(row=1, column=1, padx=10, pady=5)
    folder_button = tk.Button(root, text="Selecionar", command=select_root_folder)
    folder_button.grid(row=1, column=2, padx=10, pady=5)

    laudo_number_label = tk.Label(root, text="Número do laudo:")
    laudo_number_label.grid(row=2, column=0, padx=10, pady=5)
    entry_laudo_number = tk.Entry(root)
    entry_laudo_number.grid(row=2, column=1, padx=10, pady=5)

    attach_pdf_var = tk.BooleanVar()
    attach_pdf_checkbox = ttk.Checkbutton(root, text="Anexar PDF ao principal", variable=attach_pdf_var, command=toggle_pdf_selection)
    attach_pdf_checkbox.grid(row=3, column=0, columnspan=2, padx=10, pady=5)

    encrypt_pdf_var = tk.BooleanVar()
    encrypt_pdf_checkbox = ttk.Checkbutton(root, text="Criptografar o APÊNDICE", variable=encrypt_pdf_var, command=toggle_pdf_selection)
    encrypt_pdf_checkbox.grid(row=4, column=0, columnspan=2, padx=10, pady=5)

    password_label = tk.Label(root, text="Senha para PDF:")
    password_label.grid(row=5, column=0, padx=10, pady=5)
    password_entry = tk.Entry(root, state=tk.DISABLED, show="*")
    password_entry.grid(row=5, column=1, padx=10, pady=5)

    pdf_path_label = tk.Label(root, text="PDF principal:")
    pdf_path_label.grid(row=6, column=0, padx=10, pady=5)
    entry_pdf_path = tk.Entry(root, state=tk.DISABLED)
    entry_pdf_path.grid(row=6, column=1, padx=10, pady=5)
    pdf_button = tk.Button(root, text="Selecionar", command=select_pdf_file, state=tk.DISABLED)
    pdf_button.grid(row=6, column=2, padx=10, pady=5)

    def execute():
        folder_path = entry_folder_path.get()
        frame_rate = entry_framerate.get()
        laudo_number = entry_laudo_number.get()
        pdf_path = entry_pdf_path.get()
        attach_pdf_checked = attach_pdf_var.get()
        encrypt_pdf_checked = encrypt_pdf_var.get()
        password = password_entry.get()

        print("Executando com parâmetros:")
        print(f"folder_path={folder_path}")
        print(f"frame_rate={frame_rate}")
        print(f"laudo_number={laudo_number}")
        print(f"pdf_path={pdf_path}")
        print(f"attach_pdf_checked={attach_pdf_checked}")
        print(f"encrypt_pdf_checked={encrypt_pdf_checked}")
        # print(f"password={password}")

        if not validate_inputs(folder_path, frame_rate, laudo_number, pdf_path, attach_pdf_checked, encrypt_pdf_checked, password):
            return

        check_pdflatex()

        remove_media_files_from_root(ROOT_DIR)
        safe_remove(anime_tex_path)
        safe_remove(anime_pdf_path)
        copy_media_files_to_root(folder_path, ROOT_DIR)


        if encrypt_pdf_checked:
            # 1. Gera Anime.pdf básico
            generate_anime_tex(folder_path, frame_rate, laudo_number, anime_tex_path)
            compile_latex(anime_tex_path)
            compile_ok = compile_latex(anime_tex_path)

            if not os.path.exists(anime_pdf_path):
                messagebox.showerror("Erro", "Não foi possível gerar o Anime.pdf básico")
                return

            # 2. Criptografar o Anime.pdf
            encrypted_pdf_path = os.path.join(AUX_DIR, f"MULTIMIDIA-Laudo-{laudo_number.replace('/', '_')}.pdf")
            try:
                encrypt_pdf(anime_pdf_path, encrypted_pdf_path, password)
            except Exception as e:
                messagebox.showerror("Erro", f"Falha na criptografia: {e}")
                return

            # 3. Gerar novo Anime.tex que insere o anexo criptografado
            safe_remove(anime_tex_path)
            safe_remove(anime_pdf_path)
            generate_anime_with_attachment_tex(laudo_number, encrypted_pdf_path, anime_tex_path)

            # 4. Compilar novamente para criar Anime.pdf com anexo interno (duas vezes)
            compile_latex(anime_tex_path)
            compile_ok = compile_latex(anime_tex_path)  # segunda execução para remover a página temporária
            if not os.path.exists(anime_pdf_path):
                messagebox.showerror("Erro", "Não foi possível gerar o Anime.pdf com anexo criptografado")
                return

            messagebox.showinfo("Sucesso", "PDF Anime.pdf gerado com o apêndice criptografado embutido")

            # 5. Se for anexar ao PDF principal
            if attach_pdf_checked:
                try:
                    output_pdf_path = attach_pdf(pdf_path, anime_pdf_path)
                    size_mb = os.path.getsize(output_pdf_path) / (1024 * 1024)
                    messagebox.showinfo("Sucesso", f"PDF principal gerado com o apêndice criptografado (embutido) anexado\nTamanho: {size_mb:.2f} MB")
                    if os.path.exists(output_pdf_path):
                       os.startfile(output_pdf_path)
                except Exception as e:
                    messagebox.showerror("Erro", f"Falha ao anexar PDF: {e}")
                    return

            # Remover o PDF criptografado temporário
            safe_remove(encrypted_pdf_path)

        else:
            # Caso não criptografe
            generate_anime_tex(folder_path, frame_rate, laudo_number, anime_tex_path)
            compile_latex(anime_tex_path)
            compile_ok = compile_latex(anime_tex_path)
            if not os.path.exists(anime_pdf_path):
                messagebox.showerror("Erro", "Não foi possível gerar o Anime.pdf")
                return

            if not compile_ok:
                messagebox.showinfo("Sucesso", "PDF Anime.pdf gerado com sucesso na raiz do projeto (com advertências)")
            else:
                messagebox.showinfo("Sucesso", "PDF Anime.pdf gerado com sucesso na raiz do projeto")

            if attach_pdf_checked:
                try:
                    output_pdf_path = attach_pdf(pdf_path, anime_pdf_path)
                    size_mb = os.path.getsize(output_pdf_path) / (1024 * 1024)  
                    messagebox.showinfo("Sucesso", f"PDF principal gerado com o apêndice anexado\nTamanho: {size_mb:.2f} MB")
                    if os.path.exists(output_pdf_path):
                        os.startfile(output_pdf_path) 
                except Exception as e:
                    messagebox.showerror("Erro", f"Falha ao anexar PDF: {e}")
                    return

        remove_media_files_from_root(ROOT_DIR)

    execute_button = tk.Button(root, text="Executar", command=execute)
    execute_button.grid(row=7, column=0, columnspan=3, padx=10, pady=5)

    about_button = tk.Button(root, text="Sobre", command=show_about)
    about_button.grid(row=8, column=0, columnspan=3, padx=10, pady=5)

    help_button = tk.Button(root, text="Ajuda", command=show_help)
    help_button.grid(row=9, column=0, columnspan=3, padx=10, pady=5)

    def ask_new_execution(root):
        if messagebox.askyesno("Nova Execução", "Deseja realizar uma nova execução?"):
            entry_framerate.delete(0, tk.END)
            entry_folder_path.delete(0, tk.END)
            entry_laudo_number.delete(0, tk.END)
            entry_pdf_path.delete(0, tk.END)
            password_entry.delete(0, tk.END)  # limpa o campo de senha também
            attach_pdf_var.set(False)
            encrypt_pdf_var.set(False)
            toggle_pdf_selection()
        else:
            root.quit()

    root.protocol("WM_DELETE_WINDOW", lambda: ask_new_execution(root))
    root.mainloop()

if __name__ == "__main__":
    main()
