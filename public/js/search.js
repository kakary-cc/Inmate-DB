function search() {
    const filter = document.getElementById("searchInput").value.toUpperCase();
    console.log(filter);
    const table = document.getElementsByTagName("table")[0];
    const tr = table.getElementsByTagName("tr");

    for (let i = 1; i < tr.length; i++) {
        const tdId = tr[i].getElementsByTagName("td")[0];
        const tdName = tr[i].getElementsByTagName("td")[1];

        if (tdId || tdName) {
            const txtValueId = tdId ? tdId.textContent || tdId.innerText : "";
            const txtValueName = tdName
                ? tdName.textContent || tdName.innerText
                : "";

            tr[i].style.display =
                txtValueId.toUpperCase().indexOf(filter) > -1 ||
                txtValueName.toUpperCase().indexOf(filter) > -1
                    ? ""
                    : "none";
        }
    }
}

document.addEventListener("DOMContentLoaded", (event) => {
    document.getElementById("searchInput").addEventListener("input", search);
});
