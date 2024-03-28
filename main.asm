;        __                   
;   ____/ /___ __________ ___ 
;  / __  / __ `/ ___/ __ `__ \
; / /_/ / /_/ (__  ) / / / / /
; \__,_/\__,_/____/_/ /_/ /_/ 
;
; Dumb Assembly Socket Manager


global _start


AF_INET     equ 2
SOCK_STREAM equ 1
IP          equ 0 ; localhost
;IP          equ 0xC0A8FE10
;IP          equ 0x10FEA8C0
PORT        equ 0xD20F ; 4050 little-endian
BUFFER_SIZE equ 1024


section .bss

buffer resb BUFFER_SIZE + 1


section .data

socket_address:
.sin_family      dw AF_INET
.sin_port        dw PORT
.sin_addr.s_addr dd IP
.__pad           times 16 - ($ - socket_address) db 0x0
socket_address_length          dq $ - socket_address

start_status_msg      db "[Starting server]", 0xA, 0xA, 0
listen_status_msg     db "[SERVER]: Listening for clients...", 0xA, 0
connected_status_msg  db "[SERVER]: Client connection detected, connecting...", 0xA, 0
disconnect_status_msg db 0xA, "[SERVER]: Client IO finished, Terminating connection...", 0xA, 0

return_msg        db "HTTP/1.1 200 OK", 0xD, 0xA, 0xD, 0xA, "This server was made in x86_64 assembly on Linux.", 0xA, "I hope you enjoy it's simplistic design :D.", 0
;return_msg        db "HTTP/1.1 200 OK", 0xD, 0xA, 0xD, 0xA, "Welcome to DASM.", 0xA, "Or the Dumb Assembly Socket Manager", 0
client_prefix_msg db "[CLIENT]:", 0xA, 0

bind_error_msg   db "[ERROR]: Failed to bind socket.", 0xA, 0
listen_error_msg db "[ERROR]: Failed to listen on socket.", 0xA, 0
accept_error_msg db "[ERROR]: Failed to accept connection from client.", 0xA, 0


section .text

; Prints NULL terminated strings.
_fd_out:

    mov rax, 1
    mov rdx, rsi
    .loop:
        cmp [rdx], byte 0
        jz .loop_end
        inc rdx
        jmp .loop
    .loop_end:

    sub rdx, rsi
    syscall
    ret

; Program entry point.
_start:
    ; _fd_out(STDOUT_FILENO, start_status_msg);
    mov rdi, 1
    mov rsi, start_status_msg
    call _fd_out

    ; socket(AF_INET, SOCK_STREAM, IP);
    mov rax, 0x29
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, IP
    syscall

    ; Saving server fd.
    mov rbx, rax

    ; bind(server_file_descriptor, (struct sockaddr *)&address, sizeof(address));
    mov rax, 0x31
    mov rdi, rbx
    mov rsi, socket_address
    mov rdx, [socket_address_length]
    syscall

    ; if(bind(server_file_descriptor, (struct sockaddr *)&address, sizeof(address)) < 0) goto bind_error;
    cmp rax, 0
    jl bind_error

    ; listen(server_file_descriptor, 10);
    mov rax, 0x32
    ; This line is commented out because rdi already has rbx's contents in it.
    ;mov rdi, rbx
    mov rsi, 10
    syscall

    ; if(listen(server_file_descriptor, 10) < 0) goto listen_error;
    cmp rax, 0
    jl listen_error

    .loop:
        ; _fd_out(1, listen_status_msg);
        mov rdi, 1
        mov rsi, listen_status_msg
        call _fd_out

        ; accept(server_file_descriptor, (struct sockaddr *)&address, &address_length);
        mov rax, 0x2B
        mov rdi, rbx
        mov rsi, socket_address
        mov rdx, socket_address_length
        syscall

        ; if(accept(server_file_descriptor, (struct sockaddr *)&address, &address_length) < 0) goto accept_error;
        cmp rax, 0
        jl accept_error

        ; Saving client fd.
        push rbx
        mov rbx, rax

        ; _fd_out(1, connection_status_msg);
        mov rdi, 1
        mov rsi, connected_status_msg
        call _fd_out

        ; read(client_file_descriptor, buffer, BUFFER_SIZE);
        xor rax, rax
        mov rdi, rbx
        mov rsi, buffer
        mov rdx, BUFFER_SIZE
        syscall
        mov [buffer + rax], byte 0

        ; _fd_out(client_file_descriptor, return_msg);
        ;mov rdi, rbx
        mov rsi, return_msg
        call _fd_out

        ; _fd_out(1, client_prefix_msg);
        mov rdi, 1
        mov rsi, client_prefix_msg
        call _fd_out
        ; _fd_out(1, buffer);
        ;mov rdi, 1
        mov rsi, buffer
        call _fd_out
        ; _fd_out(1, disconnect_status_msg);
        ;mov rdi, 1
        mov rsi, disconnect_status_msg
        call _fd_out

        ; close(client_file_descriptor);
        mov rax, 0x3
        mov rdi, rbx
        syscall

        ; Retreving server fd.
        pop rbx

        jmp .loop

    ; If there was no error clear the error massage argument.
    xor rsi, rsi

    ; Error handling fall through. 
    jmp accept_error_end
    accept_error:
    mov rsi, accept_error_msg
    accept_error_end:

    jmp listen_error_end
    listen_error:
    mov rsi, listen_error_msg
    listen_error_end:

    ; close(server_file_descriptor);
    mov rax, 0x3
    mov rdi, rbx
    syscall

    jmp bind_error_end
    bind_error:
    mov rsi, bind_error_msg
    bind_error_end:

    ; Clearing the return code just in case there was no error.
    xor rdi, rdi

    ; Checking to see if there was an error message to print.
    test rsi, rsi
    jz exit
    exit_error:
    ; _fd_out(1, error_msg);
    mov rdi, 2
    call _fd_out
    mov rdi, 1

    ; exit(return_code);
    exit:
    mov rax, 0x3C
    syscall
