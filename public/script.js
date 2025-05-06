const API = 'http://localhost:3000/users';

// Función para cargar usuarios desde la API
async function fetchUsers() {
    try {
        const res = await fetch(API);
        const users = await res.json();
        const list = document.getElementById('userList');
        list.innerHTML = ''; // Limpiar la lista antes de cargar nuevos usuarios
        users.forEach(u => {
            list.innerHTML += `
                <li>
                    ${u.name} (${u.email}) 
                    <button onclick="deleteUser(${u.id})">Eliminar</button>
                </li>`;
        });
    } catch (error) {
        console.error('Error al cargar los usuarios:', error);
    }
}

// Función para agregar un usuario a la base de datos
async function addUser() {
    const name = document.getElementById('name').value;
    const email = document.getElementById('email').value;

    if (!name || !email) {
        alert('Por favor, ingrese un nombre y un correo electrónico');
        return;
    }

    try {
        await fetch(API, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ name, email })
        });
        fetchUsers(); // Actualiza la lista de usuarios después de agregar uno nuevo
    } catch (error) {
        console.error('Error al agregar el usuario:', error);
    }
}

// Función para eliminar un usuario
async function deleteUser(id) {
    try {
        await fetch(`${API}/${id}`, { method: 'DELETE' });
        fetchUsers(); // Actualiza la lista después de eliminar el usuario
    } catch (error) {
        console.error('Error al eliminar el usuario:', error);
    }
}

// Cargar los usuarios al cargar la página
fetchUsers();