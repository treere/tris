const UsernamePersistence = {
  mounted() {
    const username = localStorage.getItem("tris_username")
    if (username) {
      this.pushEvent("restore_username", { username })
    }

    this.handleEvent("save_username", ({ username }) => {
      if (username) {
        localStorage.setItem("tris_username", username)
      } else {
        localStorage.removeItem("tris_username")
      }
    })
  }
}

export default UsernamePersistence